import std.stdio;
import std.range;
import std.array;
import std.typecons;

import cl4d.all;

pragma(lib, "opencl");
pragma(lib, "cl4d");

void main(){
    Device device = clCurrent.devices.values[0][0]; ///get device info
    device.info!(Device.Info.Type).writeln;     ///get device
    
    //clDevice + array(or ptr + size) -> clBuffer
    auto vec1 = device.allocate(iota(1024).array),
         vec2 = device.allocate(iota(1024).array),
         vec3 = device.allocate!int(1024),
         vec4 = device.allocate!int(1024);
    
    //clDevice + text -> clProgram
    auto program = device.built(q{
        __kernel void vecAdd(__global int* src1, __global int* src2, __global int* result){
            int i = get_global_id(0);
            result[i] = src1[i] + src2[i];
        }
        
        __kernel void vecSub(__global int* src1, __global int* src2, __global int* result){
            int i = get_global_id(0);
            result[i] = src1[i] - src2[i];
        }
    });
    
    //clProgram -> clKernel
    auto vecAdd = program.kernel("vecAdd");
    auto vecSub = program.kernel("vecSub");
    
    //clKernel -> clKernel
    vecAdd.set([tuple(1024u, 32u)], vec1, vec2, vec3);
    vecSub.set([tuple(1024u, 32u)], vec1, vec2, vec4);
    
    //execute all task
    clCurrent.execute();
    
    writeln(vec3.array);
    writeln(vec4.array);
}