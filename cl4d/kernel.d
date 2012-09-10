module cl4d.kernel;

import cl4d.c.cl;
import cl4d.buffer;
import cl4d.program;

import std.string;
import std.typecons;
import std.array;
import std.algorithm;


///カーネルを表すためのクラスです
class Kernel{
private:
    Program _program;
    cl_kernel _kernel;

public:
    ///コンストラクタ
    this(Program program, string name){
        _program = program;
        cl_errcode err;
        _kernel = clCreateKernel(  program.clProgram,
                                            toStringz(name),
                                            &err);
        
        assert(err == CL_SUCCESS);
    }
    
    
    ~this(){
        clReleaseKernel(_kernel);
    }
    
    
    ///内部で保持している値を返します
    @property
    cl_kernel clKernel(){
        return _kernel;
    }
    
    
    ///Kernelに実行時のスレッド数と引数とセットし、実行するようにコマンドキューに入れ込みます。
    void set(SizeT, T...)(Tuple!(SizeT, SizeT)[] dims, T args)if(is(SizeT : size_t)){
        cl_errcode err;
        foreach(idx, U; T){
            static if(isBuffer!U){
                cl_mem buf = args[idx].clBuffer;
                err = clSetKernelArg(   _kernel,
                                        idx,
                                        size_t.sizeof,
                                        &buf);
            }else static if(is(U == Local)){
                err = clSetKernelArg(_kernel,
                                                idx,
                                                args[idx].size,
                                                null);
            }else{
                auto tmp = args[idx];
                err = clSetKernelArg(_kernel,
                                                idx,
                                                U.sizeof,
                                                &tmp);
            }
            
            //import std.stdio;
            //writeln(err);
            assert(err == CL_SUCCESS);
        }
        
        size_t[] global = array(map!"a[0]"(dims));
        size_t[] local =  array(map!"a[1]"(dims));
        
        err = clEnqueueNDRangeKernel(   _program.device.clCommandQueue,
                                        _kernel,
                                        dims.length,
                                        null,
                                        global.ptr,
                                        local.ptr,
                                        0,
                                        null,
                                        null);
        
        assert(err == CL_SUCCESS);
    }
}

private struct Local{}