import std.stdio        : writeln;
import std.range        : iota;
import std.algorithm    : map;
import typecons         : tuple;

import cl4d.all;

pragma(lib, "opencl");
pragma(lib, "cl4d");

void main(){
    Device device = clCurrent.platforms[0].devices[0];  //デバイスの取得
    auto dim = tuple(1024u << 4, 32u);                  //計算するときの並列スレッドの設定
    auto rng = iota(1024 << 4);                         //計算対称のレンジ(source)
    
    //paralellForeachも実装しています。返り値は結果(この場合はb)のバッファです。内部にはOpenCL Cで記述できます。
    auto result = device.parallelForeach(dim, rng, 
    q{
        b = a * 3;
    })
    
    //実際にforeachを実行した後に、結果をデバイスから受け取り、表示します
    writeln(result.array[0..100]); //[0, 3, 6, ..., 297]
}