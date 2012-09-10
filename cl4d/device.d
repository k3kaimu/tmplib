module cl4d.device;

import cl4d.c.cl;
import cl4d.platform;
import cl4d.program;
import cl4d.kernel;
import cl4d.buffer;

import std.algorithm;
import std.range;
import std.string;
import std.typecons;
import std.traits;
import std.typetuple;
import std.conv;


///cl_device_idを隠蔽する型です。
class Device{
private:
    Platform _platform;             //所属するプラットフォーム
    cl_device_id _deviceId;         //device_id
    cl_context _context;            //デバイスのコンテキスト
    cl_command_queue _commandQueue; //コマンドキュー
    //DeviceInfo  _info;

public:
    
    ///内部で保持している値を返します
    @property
    Platform platform(){
        return _platform;
    }
    
    
    ///ditto
    @property
    cl_device_id clDeviceId(){
        return _deviceId;
    }
    
    
    ///ditto
    @property
    cl_context clContext(){
        return _context;
    }
    
    
    ///ditto
    @property
    cl_command_queue clCommandQueue(){
        return _commandQueue;
    }
        
    
    ///コンストラクタ
    this(Platform platform, cl_device_id deviceId){
        _platform = platform;
        _deviceId = deviceId;
        cl_errcode err;
        
        auto id = info!(Info.Platform);
        int[] cps = [0];
        _context = clCreateContext( cast(cl_context_properties*)cps.ptr,
                                    1,
                                    &_deviceId,
                                    null,
                                    null,
                                    &err);
        assert(err == CL_SUCCESS);
        
        _commandQueue = clCreateCommandQueue(   _context,
                                                _deviceId,
                                                0,
                                                &err);
        assert(err == CL_SUCCESS);              
    }
    
    
    ~this(){
        clReleaseContext(_context);
        clReleaseCommandQueue(_commandQueue);
    }
    
    
    ///デバイスのタイプ
    enum Type : cl_bitfield{
        Default     = cl_device_type.CL_DEVICE_TYPE_DEFAULT,
        Cpu         = cl_device_type.CL_DEVICE_TYPE_CPU,
        Gpu         = cl_device_type.CL_DEVICE_TYPE_GPU,
        Accelerator = cl_device_type.CL_DEVICE_TYPE_ACCELERATOR,
        Custom      = cl_device_type.CL_DEVICE_TYPE_CUSTOM,
        All         = cl_device_type.CL_DEVICE_TYPE_ALL,
    }
    
    
    ///Deviceの情報を取得します
    template info(InfoType){
        import std.traits;
        static if(isArray!(InfoType.returnType)){
            ///ditto
            InfoType.returnType info(size_t n = 1024){
                InfoType.returnType dst;
                dst.length = n;
                size_t dstsize;
                cl_errcode err = clGetDeviceInfo(   _deviceId,
                                                InfoType.value,
                                                InfoType.returnType.sizeof * n,
                                                dst.ptr,
                                                &dstsize);
                
                assert(err == CL_SUCCESS);
                if(dstsize < ForeachType!(InfoType.returnType).sizeof * n)
                    dst = dst[0..dstsize/ForeachType!(InfoType.returnType).sizeof];
                return dst;
            }
        }else{
            ///ditto
            InfoType.returnType info(){
                InfoType.returnType dst;
                cl_errcode err = clGetDeviceInfo(   _deviceId,
                                                InfoType.value,
                                                InfoType.returnType.sizeof,
                                                &dst,
                                                null);
                assert(err == CL_SUCCESS);
                return dst;
            }
        }
    }
    
    
    ///ditto
    struct Info{
        struct Type{alias cl_device_type returnType; enum value = CL_DEVICE_TYPE;}
        struct VendorId{alias cl_uint returnType; enum value = CL_DEVICE_VENDOR_ID;}
        struct MaxComputeUnits{alias cl_uint returnType; enum value = CL_DEVICE_MAX_COMPUTE_UNITS;}
        struct MaxWorkItemDimensions{alias cl_uint returnType; enum value = CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS;}
        struct MaxWorkGroupSize{alias size_t returnType; enum value = CL_DEVICE_MAX_WORK_GROUP_SIZE;}
        struct MaxWorkItemSizes{alias size_t[] returnType; enum value = CL_DEVICE_MAX_WORK_ITEM_SIZES;}
        struct PreferredVectorWidthChar{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR;}
        struct PreferredVectorWidthShort{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT;}
        struct PreferredVectorWidthInt{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT;}
        struct PreferredVectorWidthLong{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG;}
        struct PreferredVectorWidthFloat{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT;}
        struct PreferredVectorWidthDouble{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE;}
        struct MaxClockFrequency{alias cl_uint returnType; enum value = CL_DEVICE_MAX_CLOCK_FREQUENCY;}
        struct AddressBits{alias cl_uint returnType; enum value = CL_DEVICE_ADDRESS_BITS;}
        struct MaxReadImageArgs{alias cl_uint returnType; enum value = CL_DEVICE_MAX_READ_IMAGE_ARGS;}
        struct MaxWriteImageArgs{alias cl_uint returnType; enum value = CL_DEVICE_MAX_WRITE_IMAGE_ARGS;}
        struct MaxMemAllocSize{alias cl_ulong returnType; enum value = CL_DEVICE_MAX_MEM_ALLOC_SIZE;}
        struct Image2dMaxWidth{alias size_t returnType; enum value = CL_DEVICE_IMAGE2D_MAX_WIDTH;}
        struct Image2dMaxHeight{alias size_t returnType; enum value = CL_DEVICE_IMAGE2D_MAX_HEIGHT;}
        struct Image3dMaxWidth{alias size_t returnType; enum value = CL_DEVICE_IMAGE3D_MAX_WIDTH;}
        struct Image3dMaxHeight{alias size_t returnType; enum value = CL_DEVICE_IMAGE3D_MAX_HEIGHT;}
        struct Image3dMaxDepth{alias size_t returnType; enum value = CL_DEVICE_IMAGE3D_MAX_DEPTH;}
        struct ImageSupport{alias cl_bool returnType; enum value = CL_DEVICE_IMAGE_SUPPORT;}
        struct MaxParameterSize{alias size_t returnType; enum value = CL_DEVICE_MAX_PARAMETER_SIZE;}
        struct MaxSamplers{alias cl_uint returnType; enum value = CL_DEVICE_MAX_SAMPLERS;}
        struct MemBaseAddrAlign{alias cl_uint returnType; enum value = CL_DEVICE_MEM_BASE_ADDR_ALIGN;}
        struct MinDataTypeAlignSize{alias cl_uint returnType; enum value = CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE;}
        struct SingleFpConfig{alias cl_device_fp_config returnType; enum value = CL_DEVICE_SINGLE_FP_CONFIG;}
        struct GlobalMemCacheType{alias cl_device_mem_cache_type returnType; enum value = CL_DEVICE_GLOBAL_MEM_CACHE_TYPE;}
        struct GlobalMemCachelineSize{alias cl_uint returnType; enum value = CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE;}
        struct GlobalMemCacheSize{alias cl_ulong returnType; enum value = CL_DEVICE_GLOBAL_MEM_CACHE_SIZE;}
        struct GlobalMemSize{alias cl_ulong returnType; enum value = CL_DEVICE_GLOBAL_MEM_SIZE;}
        struct MaxConstantBufferSize{alias cl_ulong returnType; enum value = CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE;}
        struct MaxConstantArgs{alias cl_uint returnType; enum value = CL_DEVICE_MAX_CONSTANT_ARGS;}
        struct LocalMemType{alias cl_device_local_mem_type returnType; enum value = CL_DEVICE_LOCAL_MEM_TYPE;}
        struct LocalMemSize{alias cl_ulong returnType; enum value = CL_DEVICE_LOCAL_MEM_SIZE;}
        struct ErrorCorrectionSupport{alias cl_bool returnType; enum value = CL_DEVICE_ERROR_CORRECTION_SUPPORT;}
        struct ProfilingTimerResolution{alias size_t returnType; enum value = CL_DEVICE_PROFILING_TIMER_RESOLUTION;}
        struct EndianLittle{alias cl_bool returnType; enum value = CL_DEVICE_ENDIAN_LITTLE;}
        struct Available{alias cl_bool returnType; enum value = CL_DEVICE_AVAILABLE;}
        struct CompilerAvailable{alias cl_bool returnType; enum value = CL_DEVICE_COMPILER_AVAILABLE;}
        struct ExecutionCapabilities{alias cl_device_exec_capabilities returnType; enum value = CL_DEVICE_EXECUTION_CAPABILITIES;}
        struct QueueProperties{alias cl_command_queue_properties returnType; enum value = CL_DEVICE_QUEUE_PROPERTIES;}
        struct Name{alias char[] returnType; enum value = CL_DEVICE_NAME;}
        struct Vendor{alias char[] returnType; enum value = CL_DEVICE_VENDOR;}
        struct DriverVersion{alias char[] returnType; enum value = CL_DRIVER_VERSION;}
        struct Profile{alias char[] returnType; enum value = CL_DEVICE_PROFILE;}
        struct Version{alias char[] returnType; enum value = CL_DEVICE_VERSION;}
        struct Extensions{alias char[] returnType; enum value = CL_DEVICE_EXTENSIONS;}
        struct Platform{alias cl_platform_id returnType; enum value = CL_DEVICE_PLATFORM;}
        struct DoubleFpConfig{alias cl_device_fp_config returnType; enum value = CL_DEVICE_DOUBLE_FP_CONFIG;}
        struct PreferredVectorWidthHalf{alias cl_uint returnType; enum value = CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF;}
        struct HostUnifiedMemory{alias cl_bool returnType; enum value = CL_DEVICE_HOST_UNIFIED_MEMORY;}
        struct NativeVectorWidthChar{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR;}
        struct NativeVectorWidthShort{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT;}
        struct NativeVectorWidthInt{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_INT;}
        struct NativeVectorWidthLong{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG;}
        struct NativeVectorWidthFloat{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT;}
        struct NativeVectorWidthDouble{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE;}
        struct NativeVectorWidthHalf{alias cl_uint returnType; enum value = CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF;}
        struct OpenclCVersion{alias char[] returnType; enum value = CL_DEVICE_OPENCL_C_VERSION;}
        struct LinkerAvailable{alias cl_bool returnType; enum value = CL_DEVICE_LINKER_AVAILABLE;}
        struct BuiltInKernels{alias char[] returnType; enum value = CL_DEVICE_BUILT_IN_KERNELS;}
        struct ImageMaxBufferSize{alias size_t returnType; enum value = CL_DEVICE_IMAGE_MAX_BUFFER_SIZE;}
        struct ImageMaxArraySize{alias size_t returnType; enum value = CL_DEVICE_IMAGE_MAX_ARRAY_SIZE;}
        struct ParentDevice{alias cl_device_id returnType; enum value = CL_DEVICE_PARENT_DEVICE;}
        struct PartitionMaxSubDevices{alias cl_uint returnType; enum value = CL_DEVICE_PARTITION_MAX_SUB_DEVICES;}
        struct PartitionProperties{alias cl_device_partition_property[] returnType; enum value = CL_DEVICE_PARTITION_PROPERTIES;}
        struct PartitionAffinityDomain{alias cl_device_affinity_domain returnType; enum value = CL_DEVICE_PARTITION_AFFINITY_DOMAIN;}
        struct PartitionType{alias cl_device_partition_property[] returnType; enum value = CL_DEVICE_PARTITION_TYPE;}
        struct ReferenceCount{alias cl_uint returnType; enum value = CL_DEVICE_REFERENCE_COUNT;}
        struct PreferredInteropUserSync{alias cl_bool returnType; enum value = CL_DEVICE_PREFERRED_INTEROP_USER_SYNC;}
        struct PrintfBufferSize{alias size_t returnType; enum value = CL_DEVICE_PRINTF_BUFFER_SIZE;}
    }
    
    
    ///デバイスにプログラムをセットし、ビルドします
    Program build(Text...)(Text text){
        return new Program(this, text);
    }
    
    
    ///このデバイスに関連付けられているコマンドをすべて実行します。
    void flush(){
        clFlush(_commandQueue);
    }
    
    
    ///このデバイスに関連付けられているコマンドをすべて実行します。
    void finish(){
        clFinish(_commandQueue);
    }
    
    
    ///このデバイスに関連付けられているコマンドをすべて実行します(同期)
    void execute(){
        flush();
        finish();
    }
    
    
    ///rangeからバッファを作って返します
    Buffer!(ElementType!Range) allocate(Range)(Range range, string flag = "rw")if(isInputRange!Range && !isInfinite!(Range)){
        auto array = array(range);
        return new typeof(return)(this, array, flag);
    }
    
    
    ///lengthの長さを持つバッファを作成し、かえします。
    Buffer!T allocate(T)(size_t length, string flag = "rw"){
        return new Buffer!T(this, length, flag);
    }
    
    /+
    ///このデバイスで単純な繰り返し動作を行うようにします
    Buffer!(ElementType!(Range))
     parallelForeach(string structStr = "", Range)
        (Tuple!(size_t, size_t) dim, Range range, string repeatBody)if(isInputRange!(Range))
    {
        alias ElementType!(Range) E;
        repeatBody = structStr ~ "\n\n__kernel void foreachFunction(__global " ~ E.stringof ~ "* range, __global " ~ E.stringof ~"* result){\n"
        ~ "size_t i = get_global_id(0);\n"
        ~ E.stringof ~ " a = range[i], b = result[i];" ~ repeatBody ~ "\n result[i] = b;\n}\n";
        
        auto rangeArray = array(take(range, dim[0]));
        if(rangeArray.length < dim[0]){
            dim[0] = rangeArray.length;
        }
        
        auto input = this.allocate(rangeArray);
        auto result = this.allocate!(typeof(range.front))(dim[0]);
        
        this.build(repeatBody).kernel("foreachFunction").set([dim], input, result);
        this.execute();
        return result;
    }+/
    
    ///このデバイスで単純な繰り返し動作を行います。
    void Foreach(string header = "", I, Captures...)(Tuple!(I, I)[] dims, Captures captures, string repeatBody)
    in{
        assert(dims.length <= 3);
        assert(dims.length != 0);
    }
    body{
        
        
        string[string] createTupleHeaders(){
            string[string] dst;
            
            foreach(i, C; Captures){
                alias Unqual!C E;
                
                static if(isTuple!E){
                    auto code = createTupleCode!E();
                    dst[code.name] ~= code.code ~ "\n";
                }else static if(isInputRange!E && isTuple!(ElementType!E)){
                    auto code = createTupleCode!(ElementType!E)();
                    dst[code.name] ~= code.code ~ "\n";
                }else static if(isBuffer!E && isTuple!(typeof(E.init.array[0]))){
                    auto code = createTupleCode!(typeof(E.init.array[0]))();
                    dst[code.name] ~= code.code ~ "\n";
                }
            }
            
            return dst;
        }
        
        string cbody = header ~ "\n";
        
        foreach(e; createTupleHeaders().values){
            cbody ~= e;
        }
        
        cbody ~= "\n\n__kernel void foreachFunction(";
        
        foreach(i, C; Captures){
            alias Unqual!C U;
            static if(isInputRange!U){
                static if(isTuple!(ElementType!U)){
                    alias typeof(ElementType!U.init.tupleof) K;
                    cbody ~= "__global Tuple";
                    
                    foreach(k; K)
                        cbody ~= "_" ~ k.stringof;
                    cbody ~= "* " ~ cast(immutable(char))('a' + i);
                }else
                    cbody ~= "__global " ~ ElementType!(U).stringof ~ "* " ~ cast(immutable(char))('a' + i);
            }else static if(isBuffer!U){
                alias typeof(U.init.array[0]) V;
                static if(isTuple!V){
                    alias typeof(V.init.tupleof) K;
                    cbody ~= "__global Tuple";
                    
                    foreach(k; K)
                        cbody ~= "_" ~ k.stringof;
                    cbody ~= "* " ~ cast(immutable(char))('a' + i);
                }else
                    cbody ~= "__global " ~ V.stringof ~ "* " ~ cast(immutable(char))('a' + i);
            }else{
                static if(isTuple!U){
                    alias typeof(U.init.tupleof) K;
                    cbody ~= "Tuple";
                    
                    foreach(k; TypeTuple!(K))
                        cbody ~= "_" ~ k.stringof;
                    cbody ~= "* " ~ cast(immutable(char))('a' + i);
                }else
                    cbody ~= toCLC(U.stringof) ~ " " ~ cast(immutable(char))('a' + i);
            }
            
            cbody ~= ", ";
        }
        
        cbody = cbody[0..$-2] ~ ")\n{\n";
        
        foreach(i; 0..dims.length){
            cbody ~= "    size_t " ~ cast(immutable(char))('i' + i) ~ " = get_global_id(" ~ to!string(i) ~ ");\n"; 
        }
        
        cbody ~= repeatBody ~ "\n}\n";
        
        auto buf = toBuffer(captures);
        import std.stdio;
        //writeln(cbody);
        this.build(cbody).kernel("foreachFunction").set(dims, buf.field);
        
        this.execute();
    }
    
    private Tuple!(string, "name", string, "code") createTupleCode(T)(T a = T.init)if(isTuple!T){
        alias typeof(T.init.tupleof) E;
        static assert(allSatisfy!(isBasicType, E), "Foreach can get array, or tuple of basic types, or OpenCL C basic type.");
        
        string name = " Tuple_";
        string cbody;
        
        foreach(int i, e; E){
            name ~= e.stringof ~ "_";
            cbody ~= "    " ~ toCLC(e.stringof) ~ " field_" ~ to!string(i) ~ ";\n";
        }
        name = name[0..$-1];
        
        return typeof(return)(T.stringof, "typedef struct" ~ name ~ "{\n" ~ cbody ~ "}" ~ name ~ ";\n");
    }
    
    private string toCLC(string type){
        if(type[0] == 'u')
            return "unsigned " ~ type[1..$];
        else
            return type;
    }
    
    private template BufferType(T){
        static if(isInputRange!T)
            alias Buffer!(ElementType!T) BufferType;
        else
            alias T BufferType;
    }
    
    
    private Tuple!(staticMap!(BufferType, T)) toBuffer(T...)(T args){
        typeof(return) dst;
        
        foreach(i, E; T){
            static if(isInputRange!E)
                dst[i] = this.allocate(args[i]);
            else
                dst[i] = args[i];
        }
        
        return dst;
    }
    
    
    template isTuple(T){
        enum bool isTuple = is(typeof({
           T a;
           auto e0 = a[0];
           static assert(!is(typeof({
                T b;
                size_t n;
                auto e1 = b[n];
           })));
        }));
    }
    
}
