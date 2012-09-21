import std.stdio;
import std.range;
import std.array;
import std.typecons;

import cl4d.all;

pragma(lib, "opencl");
pragma(lib, "cl4d");

//q{}の中身はOpenCL Cでかかれたデバイス用のプログラムで、N次元ベクトルの和と差です。
string clSrc = q{
    __kernel void vecAdd(__constant int* src1, __constant int* src2, __global int* result){
        int i = get_global_id(0);
        result[i] = src1[i] + src2[i];
    }
};

void main(){
    //デバイスを得ます。clCurrentはプログラム開始時の実行環境を表します。
    with(OpenCL.platforms[0].devices[0]) //with便利
    {
        //デバイスの情報を得ます。返り値の方はDevice.Info.****によって異なります
        info!(Device.Info.Vendor).writeln;
        //デバイスのメモリを確保します。配列を渡すとその値をコピーし、int型を渡すとその大きさのメモリを確保します
        auto vec1 = allocate(iota(1024).array, "r"),
             vec2 = vec1.copy,
             vec3 = allocate!int(1024),
             vec4 = vec3.copy;
        
        //clSrcをビルドします。
        auto program = build(clSrc, File(`C:\mylibrary\cl4d\_vecSub.cl`));
        
        //内部のタスクを並列で処理を行います。vecAddとvecSubは同時に行われる可能性があります
        taskManager.parallel({
            //デバイスに関連付けられているコマンドキューにカーネルを実行することを設定します
            program.vecAdd(vec1, vec2, vec3)(tuple(1024u, 32u))
            .after({                   //コマンドキューにアクセスする操作ではほとんどの関数がEventを返します。
                writeln("End vecAdd");  //Event.afterは、受け取ったdelegateをイベント発火時に実行するように設定します。
            });
            
            //マニュアル的にカーネルの引数を設定する方式も可能
            auto vecSub = program.vecSub;
            vecSub.setParameter!0(vec1);    //マニュアル的に引数セット可能
            vecSub.setParameter!1(vec2);
            vecSub.setParameter!2(vec4);
            vecSub(tuple(1024u, 32u))
            .after({
                writeln("End vecSub");
            });
            
        }); //自動的にコマンドキューにbarrierが入るので、並列タスク以外の実行順序は守られます
        
        //device.taskManager.markCurrentPointは、現在のポイントが実行された場合に発火するイベントを返します。
        //この場合はtaskManager.parallelの部分が終わった直後に発火されるイベントになります。
        taskManager.markCurrentPoint.after({
            writeln("OK, here is out of the taskManager.parallel scope.");
        });
        
        writeln("start !!");
        
        //結果を出力します。 Array.arrayはデバイスに関連付けられているコマンドキューに溜まっているコマンドを実行し、Bufferから設定したデータ量を読み込みます
        writeln(vec3[0..10].array);    //[0, 2, 4, 6, 8, ...]
        writeln(vec4[0..10].array);    //[0, 0, 0, 0, 0, ...]
        
        vec4.copy(vec3);        //デバイスメモリ間のコピー
        writeln(vec4[0..10].array);    //[0, 2, 4, 6, 8, ...]
    }
}
