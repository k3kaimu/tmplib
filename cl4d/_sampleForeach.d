import std.stdio        : writeln;
import std.typecons;

import cl4d.all;

pragma(lib, "opencl");
pragma(lib, "cl4d");

void main(){
    Device device = clCurrent.platforms[0].devices[0];  //デバイスの取得
    auto dims = [tuple(8u, 8u), tuple(8u, 8u)];       //計算するときの並列スレッドの設定
    auto vector = device.allocate!(Tuple!(int, ulong))(64);
    
    device.Foreach(dims, vector, q{
        a[i * 8 + j].field_0 = j;
        a[i * 8 + j].field_1 = i * 8 + j;
    });
    
    writeln(vector.array);
    //[Tuple!(int,ulong)(0, 0), Tuple!(int,ulong)(1, 1), Tuple!(int,ulong)(2, 2), Tuple!(int,ulong)(3, 3), Tuple!(int,ulong)(4, 4), Tuple!(int,ulong)(5, 5), Tuple!(int,ulong)(6, 6), Tuple!(int,ulong)(7, 7), Tuple!(int,ulong)(0, 8), Tuple!(int,ulong)(1, 9), Tuple!(int,ulong)(2, 10), Tuple!(int,ulong)(3, 11), Tuple!(int,ulong)(4, 12), Tuple!(int,ulong)(5, 13), Tuple!(int,ulong)(6, 14), Tuple!(int,ulong)(7, 15),
    // Tuple!(int,ulong)(0, 16), Tuple!(int,ulong)(1, 17), Tuple!(int,ulong)(2, 18), Tuple!(int,ulong)(3, 19), Tuple!(int,ulong)(4, 20), Tuple!(int,ulong)(5, 21), Tuple!(int,ulong)(6, 22), Tuple!(int,ulong)(7, 23), Tuple!(int,ulong)(0, 24), Tuple!(int,ulong)(1, 25), Tuple!(int,ulong)(2, 26), Tuple!(int,ulong)(3, 27), Tuple!(int,ulong)(4, 28), Tuple!(int,ulong)(5, 29), Tuple!(int,ulong)(6, 30), Tuple!(int,ulong)(7, 31),
    // Tuple!(int,ulong)(0, 32), Tuple!(int,ulong)(1, 33), Tuple!(int,ulong)(2, 34), Tuple!(int,ulong)(3, 35), Tuple!(int,ulong)(4, 36), Tuple!(int,ulong)(5, 37), Tuple!(int,ulong)(6, 38), Tuple!(int,ulong)(7, 39), Tuple!(int,ulong)(0, 40), Tuple!(int,ulong)(1, 41), Tuple!(int,ulong)(2, 42), Tuple!(int,ulong)(3, 43), Tuple!(int,ulong)(4, 44), Tuple!(int,ulong)(5, 45), Tuple!(int,ulong)(6, 46), Tuple!(int,ulong)(7, 47),
    // Tuple!(int,ulong)(0, 48), Tuple!(int,ulong)(1, 49), Tuple!(int,ulong)(2, 50), Tuple!(int,ulong)(3, 51), Tuple!(int,ulong)(4, 52), Tuple!(int,ulong)(5, 53), Tuple!(int,ulong)(6, 54), Tuple!(int,ulong)(7, 55), Tuple!(int,ulong)(0, 56), Tuple!(int,ulong)(1, 57), Tuple!(int,ulong)(2, 58), Tuple!(int,ulong)(3, 59), Tuple!(int,ulong)(4, 60), Tuple!(int,ulong)(5, 61), Tuple!(int,ulong)(6, 62), Tuple!(int,ulong)(7, 63)]
}

//生成されるデバイス側のコードは以下のようになります
/*
typedef struct Tuple_int_ulong{
    int field_0;
    unsigned long field_1;
} Tuple_int_ulong;

__kernel void foreachFunction(__global Tuple_int_ulong* a)
{
    size_t i = get_global_id(0);
    size_t j = get_global_id(1);

        a[i * 8 + j].field_0 = j;
        a[i * 8 + j].field_1 = i * 8 + j;
    
}
*/