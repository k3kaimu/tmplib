module cl4d.program;

import cl4d.c.cl;
import cl4d.device;
import cl4d.kernel;
import cl4d.taskmanager;

import std.array;
import std.algorithm;
import std.typecons;

///デバイスに関連付けられているプログラムを表します
class Program{
private:
    Device  _device;
    cl_program _program;
    
public:
    ///コンストラクタ。ファイルや文字列からプログラムを作製し、ビルドします
    this(Text...)(Device device, Text files){
        _device = device;
        string[] codes;
        foreach(i, T; Text){
            static if(is(T == std.stdio.File)){
                string src;
                foreach(s; files[i].byLine)
                    src ~= s;
                
                codes ~= src;
            }else static if(is(T : string)){
                codes ~= files[i];
            }else{
                static assert(0);
            }
        }
        
        immutable(char)*[] cps = array(map!"a.ptr"(codes));
        size_t[] lengths = array(map!"a.length"(codes));
        cl_errcode err;
        
        _program = clCreateProgramWithSource(   _device.clContext,
                                                codes.length,
                                                cps.ptr,
                                                lengths.ptr,
                                                &err);
        
        assert(err == CL_SUCCESS);
        
        cl_device_id di = _device.clDeviceId();
        
        err = clBuildProgram(   _program,
                                1,
                                &di,
                                null,
                                null,
                                &err);
        //import std.stdio;
        //writeln(err);
        assert(err == CL_SUCCESS);
    }
    
    
    ~this(){
        clReleaseProgram(_program);
    }
    
    
    ///内部で保持している値を返します
    @property
    Device device(){
        return _device;
    }
    
    
    ///ditto
    @property
    cl_program clProgram(){
        return _program;
    }
    
    
    ///カーネルを取得します
    Kernel kernel(string kernelName){
        return new Kernel(this, kernelName);
    }
    
    
    ///opDispatch
    Event opDispatch(string kernelName, T...)(Tuple!(size_t, size_t)[] dims, T args){
        auto kernel = new Kernel(this, kernelName);
        return kernel.set(dims, args);
    }
}