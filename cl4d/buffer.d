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
    cl_mem buffer(){
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
            _length = arr.length;
            
            cl_errcode err;
            _buffer = clCreateBuffer(   _device.clContext,
                                        _flag,
                                        _length * T.sizeof,
                                        null,
                                        &err);
            assert(err == CL_SUCCESS);
            
            
        }
    }
    
    
    ///バッファの大きさを取得します。バイト値にするにはT.sizeof倍してください
    @property
    size_t length(){
        return _length;
    }
}