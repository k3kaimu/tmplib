module cl4d.platform;

import cl4d.c.cl;
import cl4d.device;

///cl_platform_idを隠蔽する型
class Platform{
private:
    cl_platform_id _platform;
    
public:
    this(cl_platform_id clPlatformID){
        _platform = clPlatformID;
    }
    
    ///idを取得します
    @property
    cl_platform_id clPlatformId(){
        return _platform;
    }
    
    
    ///Platformの情報を取得します。
    @property
    string info(Info info, size_t maxLength = 1024){
        char[] result = new char[maxLength];
        size_t _length;
        cl_errcode err = clGetPlatformInfo( _platform,
                                        info,
                                        maxLength,
                                        result.ptr,
                                        &_length);
        result.length = _length;
        return cast(string)(result.dup);
    }
    
    
    ///ditto
    enum Info : cl_platform_info{
        Profile     = CL_PLATFORM_PROFILE,
        Version     = CL_PLATFORM_VERSION,
        Name        = CL_PLATFORM_NAME,
        Vendor      = CL_PLATFORM_VENDOR,
        Extensions  = CL_PLATFORM_EXTENSIONS
    }
    
    
    ///deviceTypeなdeviceを取得します。
    Device[] devices(Device.Type deviceType = Device.Type.All)
    {
        import std.stdio;
        cl_uint num;
        cl_device_id[] devices;
        cl_errcode err = clGetDeviceIDs(_platform,
                                    *cast(cl_device_type*)&deviceType,
                                    0,
                                    null,
                                    &num);
        
        devices = new cl_device_id[num];
        
        err = clGetDeviceIDs(_platform,
                             *cast(cl_device_type*)&deviceType,
                             num,
                             devices.ptr,
                             null);
        assert(err == CL_SUCCESS);

        Device[] dst;
        
        foreach(d; devices)
            dst ~= new Device(this, d);
        
        return dst;
    }
}
