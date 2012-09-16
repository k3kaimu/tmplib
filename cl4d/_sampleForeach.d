import std.stdio        : writeln;
import std.typecons;

import cl4d.all;

pragma(lib, "opencl");
pragma(lib, "cl4d");

void main(){
    Device device = clCurrent.platforms[0].devices[0];  //デバイスの取得
    auto dims = [tuple(8u, 8u), tuple(8u, 8u)];         //計算するときの並列スレッドの設定
    auto vector1 = device.allocate!(Tuple!(int, ulong))(64);
    auto vector2 = device.allocate!(int)(64);
    auto vector3 = device.allocate!(ulong)(64);
    
    device.Foreach(dims, vector1, vector2, vector3, cast(immutable)8u, q{
        size_t idx = i * d + j;
        a[idx].field_0 = j;
        a[idx].field_1 = i * d + j;
        
        b[idx] = i;
        c[idx] = j;
    }).after({writeln("End calculation");});
    
    writeln(vector1.array[0..16]);
    //[Tuple!(int,ulong)(0, 0), Tuple!(int,ulong)(1, 1), Tuple!(int,ulong)(2, 2), Tuple!(int,ulong)(3, 3), Tuple!(int,ulong)(4, 4), Tuple!(int,ulong)(5, 5), Tuple!(int,ulong)(6, 6), Tuple!(int,ulong)(7, 7), Tuple!(int,ulong)(0, 8), Tuple!(int,ulong)(1, 9), Tuple!(int,ulong)(2, 10), Tuple!(int,ulong)(3, 11), Tuple!(int,ulong)(4, 12), Tuple!(int,ulong)(5, 13), Tuple!(int,ulong)(6, 14), Tuple!(int,ulong)(7, 15),
    // Tuple!(int,ulong)(0, 16), Tuple!(int,ulong)(1, 17), Tuple!(int,ulong)(2, 18), Tuple!(int,ulong)(3, 19), Tuple!(int,ulong)(4, 20), Tuple!(int,ulong)(5, 21), Tuple!(int,ulong)(6, 22), Tuple!(int,ulong)(7, 23), Tuple!(int,ulong)(0, 24), Tuple!(int,ulong)(1, 25), Tuple!(int,ulong)(2, 26), Tuple!(int,ulong)(3, 27), Tuple!(int,ulong)(4, 28), Tuple!(int,ulong)(5, 29), Tuple!(int,ulong)(6, 30), Tuple!(int,ulong)(7, 31)]
    
    writeln(vector2.array[0..16]);  //[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1]
    writeln(vector3.array[0..16]);  //[0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7]
}
