import std.stdio;
import std.range;
import std.array;
import std.typecons;

import cl4d.all;

pragma(lib, "opencl");
pragma(lib, "cl4d");

//q{}の中身はOpenCL Cでかかれたデバイス用のプログラムで、N次元ベクトルの和と差です。
string clSrc = q{
    __kernel void vecAdd(__global int* src1, __global int* src2, __global int* result){
        int i = get_global_id(0);
        result[i] = src1[i] + src2[i];
    }
    
    __kernel void vecSub(__global int* src1, __global int* src2, __global int* result){
        int i = get_global_id(0);
        result[i] = src1[i] - src2[i];
    }
};

void main(){
    //デバイスを得ます。clCurrentはプログラム開始時の実行環境を表します。
    Device device = clCurrent.platforms[0].devices[0];
    
    //デバイスの情報を得ます。返り値の方はDevice.Info.****によって異なります
    device.info!(Device.Info.Vendor).writeln;           
    
    //デバイスのメモリを確保します。配列を渡すとその値をコピーし、int型を渡すとその大きさのメモリを確保します
    auto vec1 = device.allocate(iota(1024).array),
         vec2 = device.allocate(iota(1024).array),
         vec3 = device.allocate!int(1024),
         vec4 = device.allocate!int(1024);
    
    //clSrcをビルドします
    auto program = device.build(clSrc);
    
    //デバイスに関連付けられているコマンドキューにカーネルを実行することを設定します
    program.vecAdd([tuple(1024u, 32u)], vec1, vec2, vec3);
    program.vecSub([tuple(1024u, 32u)], vec1, vec2, vec4);
    
    //結果を出力します。 Buffer.arrayはデバイスに関連付けられているコマンドキューに溜まっているコマンドを実行し、Bufferから設定したデータ量を読み込みます
    writeln(vec3.array);    //[0, 2, 4, 6, 8, ...]
    writeln(vec4.array);    //[0, 0, 0, 0, 0, ...]
}
