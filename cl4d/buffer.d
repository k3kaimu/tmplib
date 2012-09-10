module cl4d.buffer;

import cl4d.c.cl;
import cl4d.device;

///デバイスのメモリ空間のバッファを表します
class Buffer(T){
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
        
        final switch(flag){
            case "r":
                _flag = cl_mem_flags.CL_MEM_READ_ONLY;
                break;
            case "w":
                _flag = cl_mem_flags.CL_MEM_WRITE_ONLY;
                break;
            case "rw":
                _flag = cl_mem_flags.CL_MEM_READ_WRITE;
                break;
        }
        
        _buffer = clCreateBuffer(   _device.clContext,
                                    _flag,
                                    length * T.sizeof,
                                    null,
                                    &err);
        assert(err == CL_SUCCESS);
        
    }
    
    
    ///バッファを指定してBufferを作ります
    this(Device device, T[] buf, string flag = "rw"){
        this(device, buf.length, flag);
        
        cl_int err;
        
        err = clEnqueueWriteBuffer( _device.clCommandQueue,
                                    _buffer,
                                    true,
                                    0,
                                    _length * T.sizeof,
                                    buf.ptr,
                                    0,
                                    null,
                                    null);
        assert(err == CL_SUCCESS);
    }
    
    
    ~this(){
        clReleaseMemObject(_buffer);
    }
    
    
    ///保持している値を返します
    @property
    cl_mem clBuffer(){
        return _buffer;
    }
    
    
    ///
    @property
    Device device(){
        return _device;
    }
    
    
    ///バッファから値を取得します
    @property
    T[] array(){
        cl_errcode err;
        
        T[] dst = new T[_length];
        
        err = clEnqueueReadBuffer(  device.clCommandQueue,
                                    _buffer,
                                    CL_TRUE,
                                    0,
                                    _length * T.sizeof,
                                    dst.ptr,
                                    0,
                                    null,
                                    null);
        assert(err == CL_SUCCESS);
        
        return dst;
    }
    
    
    ///バッファに値を書き込みます
    @property
    void array(T[] arr){
        if(_allocLength > arr.length){
            _length = arr.length;
            
            cl_errcode err = clEnqueueWriteBuffer(  _device.clCommandQueue,
                                                    _buffer,
                                                    true,
                                                    0,
                                                    _length * T.sizeof,
                                                    arr.ptr,
                                                    0,
                                                    null,
                                                    null);
        }else{
            this.length(arr.length);
            array(arr);
        }
    }
    
    
    ///バッファにバッファをコピーします。
    @property
    void copy(Buffer src)
    in{
        assert(src.device.clDeviceId == _device.clDeviceId);
    }
    body{
        this.length(src.length);
        cl_errcode err = clEnqueueCopyBuffer(   _device.clCommandQueue,
                                                src.clBuffer,
                                                _buffer,
                                                0,
                                                0,
                                                src.length * T.sizeof,
                                                0,
                                                null,
                                                null);
        assert(err == CL_SUCCESS);
    }
    
    
    ///コピーを返します
    @property
    Buffer copy()
    {
        auto buf = _device.allocate!T(_allocLength);
        buf.copy(this);
        return buf;
    }
    
    
    ///バッファの大きさを取得します。バイト値にするにはT.sizeof倍してください
    @property
    size_t length(){
        return _length;
    }
    
    ///バッファの長さを変更します。もしバッファの長さが取得済みより長い場合には、デバイスに溜まっているコマンドキューを消化した後に確保を行います。
    @property
    void length(size_t newLength){
        if(_allocLength >= newLength){
            _length = newLength;
        }else{
            cl_errcode err;
            _allocLength = newLength;
            cl_mem newBuffer = clCreateBuffer(  _device.clContext,
                                                _flag,
                                                _allocLength * T.sizeof,
                                                null,
                                                &err);
            
            err = clEnqueueCopyBuffer(  _device.clCommandQueue,
                                        _buffer,
                                        newBuffer,
                                        0,
                                        0,
                                        _length * T.sizeof,
                                        0,
                                        null,
                                        null);
            assert(err == CL_SUCCESS);
            _device.execute();
            
            _length = _allocLength;
            clReleaseMemObject(_buffer);
            _buffer = newBuffer;
        }
    }
}


///型TがBufferかどうか
template isBuffer(T){
    static if(is(typeof({T a; auto b = a.array;}))){
        static if(is(T == Buffer!(typeof(T.init.array[0]))))
            enum isBuffer = true;
        else
            enum isBuffer = false;
    }else
        enum isBuffer = false;
}