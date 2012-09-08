module cl4d.current;

import cl4d.c.cl;
import cl4d.platform;
import cl4d.device;

///プログラムが使用可能なリソースを表します。
Current clCurrent;

static this(){
    clCurrent = new Current();
}


///ditto
class Current{
private:
    //使用可能なplatformのリストです
    Platform[] enablePlatforms;

    //platform毎の使用可能なdeviceのリストです
    Device[][Platform] enableDevices;

public:
    this(){
        cl_uint num;
        cl_errcode err = clGetPlatformIDs(0,
                                    null,
                                    &num);
        
        cl_platform_id[] _pfs = new cl_platform_id[num];
        err = clGetPlatformIDs( num,
                                _pfs.ptr,
                                null);
        assert(err == CL_SUCCESS);

        foreach(pId; _pfs)
            enablePlatforms ~= new Platform(pId);

        foreach(pf; enablePlatforms)
            enableDevices[pf] ~= pf.devices();
    }

    
    ///プログラムで使用可能なopenclのプラットフォームの一覧を返す
    @property
    Platform[] platforms(){
        return enablePlatforms;
    }
    
    
    ///プログラムで使用可能なopencl対応デバイスを返す
    @property
    Device[][Platform] devices(){
        return enableDevices;
    }
    
    
    ///すべてのデバイスで処理が終了するまで待つ
    void finish(){
        foreach(ds; enableDevices.values)
            foreach(d; ds)
                d.finish();
    }
    
    
    ///すべてのデバイスに関連付けられているコマンドキューを実行します
    void flush(){
        foreach(ds; enableDevices.values)
            foreach(d; ds)
                d.flush();
    }
    
    
    ///すべてのデバイスに関連付けられているコマンドキューをすべて実行します(同期)
    void execute(){
        this.flush();
        this.finish();
    }
}