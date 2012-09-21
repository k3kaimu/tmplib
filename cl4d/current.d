module cl4d.current;

import cl4d.c.cl;
import cl4d.platform;
import cl4d.device;
import cl4d.taskmanager;


static this(){
    OpenCL = new Current();
}


///プログラムが使用可能なリソースを表します。
Current OpenCL;


///ditto
class Current{
private:
    //使用可能なplatformのリストです
    Platform[] enablePlatforms;

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
    }

    
    ///プログラムで使用可能なopenclのプラットフォームの一覧を返す
    @property
    Platform[] platforms(){
        return enablePlatforms;
    }
    
    
    ///すべてのデバイスで処理が終了するまで待つ
    void finish(){
        foreach(p; enablePlatforms)
            foreach(d; p.devices)
                d.finish();
    }
    
    
    ///すべてのデバイスに関連付けられているコマンドキューを実行します
    void flush(){
        foreach(p; enablePlatforms)
            foreach(d; p.devices)
                d.flush();
    }
    
    
    ///すべてのデバイスに関連付けられているコマンドキューをすべて実行します(同期)
    void execute(){
        this.flush();
        this.finish();
    }
}