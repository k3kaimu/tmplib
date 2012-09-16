module cl4d.buffer;

import cl4d.c.cl;
import cl4d.device;
import cl4d.taskmanager;

import std.algorithm : min;

 
///デバイスのメモリ空間のバッファを表します
class Buffer{
private:
    Device _device;
    cl_mem _buffer;
    size_t _length;
    size_t _allocLength;
    cl_mem_flags _flag;
    
public:
    ///長さを指定してBufferを作ります
    this(Device device, size_t length, string flag = "rw"){
        _device = device;
        _length = length;
        _allocLength = length;
        
        cl_errcode err;
        
        switch(flag){
            case "r":
                _flag = cl_mem_flags.CL_MEM_READ_ONLY;
                break;
            case "w":
                _flag = cl_mem_flags.CL_MEM_WRITE_ONLY;
                break;
            case "rw":
                _flag = cl_mem_flags.CL_MEM_READ_WRITE;
                break;
            default:
                assert(0, "flag can not be \"" ~ flag ~"\" .");
        }
        
        _buffer = clCreateBuffer(   _device.clContext,
                                    _flag,
                                    length,
                                    null,
                                    &err);
        assert(err == CL_SUCCESS);
        
    }
    
    
    ~this(){
        clReleaseMemObject(_buffer);
    }
    
    
    ///保持している値を返します
    @property
    cl_mem clMem(){
        return _buffer;
    }
    
    
    ///所属元のデバイスを返します。
    @property
    Device device(){
        return _device;
    }

    
    ///バッファの大きさを取得します。単位はbyteです。
    @property
    size_t length(){
        return _length;
    }
    
}


///Device上のメモリ空間(スライス)を示します
struct Array(T){
private:
    Buffer          _buffer;
    size_t          _offset;
    size_t          _length;

public:
    ///バッファからスライスを作ります
    this(Buffer buffer, size_t offset, size_t length){
        assert(buffer.length >= (offset + length) * T.sizeof);
        _buffer = buffer;
        _offset = offset;
        _length = length;
    }
    
    
    ///管理しているバッファを返します。
    Buffer buffer(){
        return _buffer;
    }
    
    
    ///配列の長さを返します。
    size_t length(){
        return _length;
    }
    
    
    ///デバイス上の配列について、配列長を調節します。もし、確保されたメモリ以上を取得していた場合にはそのメモリ領域を削除し、新しく確保します。
    void length(size_t newLength){
        if(_buffer.length > (_offset + newLength) * T.sizeof){
            _length = newLength;
        }else{
            Array newBuffer = _buffer.device.allocate!T(newLength * 2);
            
            Buffer s = _buffer;
            Buffer d = newBuffer.buffer;
            _buffer.device.taskManager.addTask({
                cl_event event;
                cl_errcode err = clEnqueueCopyBuffer(  _buffer.device.taskManager.clCommandQueue,
                                                        s.clMem,
                                                        d.clMem,
                                                        _offset,
                                                        0,
                                                        _length * T.sizeof,
                                                        0,
                                                        null,
                                                        &event);
                assert(err == CL_SUCCESS);
                return event;
            });
            _buffer = newBuffer._buffer;
            _offset = newBuffer._offset;
            _length = newBuffer._length;
        }
    }
    
    
    ///スライス
    Array opSlice(){
        return this;
    }
    
    
    ///ditto
    Array opSlice(size_t idx1, size_t idx2){
        return Array(_buffer, _offset + idx1, idx2 - idx1);
    }
    
    
    ///バッファから値を取得します
    @property
    T[] array(){
        cl_errcode err;
        
        T[] dst = new T[_length];
        
        err = clEnqueueReadBuffer(  _buffer.device.taskManager.clCommandQueue,
                                    _buffer.clMem,
                                    false,
                                    _offset,
                                    _length * T.sizeof,
                                    dst.ptr,
                                    0,
                                    null,
                                    null);
        assert(err == CL_SUCCESS);
        
        _buffer.device.taskManager.execute();
        
        return dst;
    }
    
    
    ///バッファに値を書き込みます
    @property
    Event copy(T[] arr){
        auto dup = arr.dup;
        
        return _buffer.device.taskManager.addTask({
            cl_event event;
            cl_errcode err = clEnqueueWriteBuffer(  _buffer.device.taskManager.clCommandQueue,
                                                    _buffer.clMem,
                                                    false,
                                                    0,
                                                    min(_length, dup.length) * T.sizeof,
                                                    dup.ptr,
                                                    0,
                                                    null,
                                                    &event);
            assert(err == CL_SUCCESS);
            return event;
        });
    }
    
    
    ///バッファにバッファをコピーします。
    @property
    Event copy(Array src)
    in{
        assert(src.buffer.device.clDeviceId == _buffer.device.clDeviceId);
    }
    body{
        Buffer s = src.buffer;
        Buffer d = _buffer;
        return _buffer.device.taskManager.addTask({
            cl_event event;
            cl_errcode err = clEnqueueCopyBuffer(   _buffer.device.taskManager.clCommandQueue,
                                                    src.buffer.clMem,
                                                    _buffer.clMem,
                                                    0,
                                                    0,
                                                    src.length * T.sizeof,
                                                    0,
                                                    null,
                                                    &event);
            assert(err == CL_SUCCESS);
            return event;
        });
    }
    
    
    ///コピーを返します
    @property
    Array copy()
    {
        auto buf = _buffer.device.allocate!T(_length);
        buf.copy(this);
        return buf;
    }

}


template isArray(T){
    static if(is(typeof({auto a = T.init.array;}))){
        static if(is(T == Array!(typeof(T.init.array[0]))))
            enum isArray = true;
        else
            enum isArray = false;
    }else{
        enum isArray = false;
    }
}
