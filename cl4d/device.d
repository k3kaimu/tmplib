module cl4d.device;

import cl4d.c.cl;

import std.algorithm;
import std.range;
import std.string;
import std.typecons;


///cl_device_idを隠蔽する型です。
class Device{
private:
    cl_device_id _deviceId;
    cl_context _context;
    cl_command_queue _commandQueue;

public:
    
    ///内部で保持している値を返します
    @property
    cl_device_id deviceId(){
        return _deviceId;
    }
    
    
    ///ditto
    @property
    cl_context context(){
        return _context;
    }
    
    
    ///ditto
    @property
    cl_command_queue commandQueue(){
        return _commandQueue;
    }
        
    
    ///コンストラクタ
    this(cl_device_id deviceId){
        _deviceId = deviceId;
        cl_errcode err;
        
        _context = clCreateContext( null,
                                    1,
                                    &_deviceId,
                                    null,
                                    null,
                                    &err);
        
        assert(err == CL_SUCCESS);
        
        _commandQueue = clCreateCommandQueue(   _context,
                                                _deviceId,
                                                cl_bitfield(0),
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
                if(dstsize < InfoType.returnType.sizeof * n)
                    dst = dst[0..dstsize/InfoType.returnType.sizeof];
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
        struct Name{alias string returnType; enum value = CL_DEVICE_NAME;}
        struct Vendor{alias string returnType; enum value = CL_DEVICE_VENDOR;}
        struct DriverVersion{alias string returnType; enum value = CL_DRIVER_VERSION;}
        struct Profile{alias string returnType; enum value = CL_DEVICE_PROFILE;}
        struct Version{alias string returnType; enum value = CL_DEVICE_VERSION;}
        struct Extensions{alias string returnType; enum value = CL_DEVICE_EXTENSIONS;}
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
        struct OpenclCVersion{alias string returnType; enum value = CL_DEVICE_OPENCL_C_VERSION;}
        struct LinkerAvailable{alias cl_bool returnType; enum value = CL_DEVICE_LINKER_AVAILABLE;}
        struct BuiltInKernels{alias string returnType; enum value = CL_DEVICE_BUILT_IN_KERNELS;}
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
    Program built(Text...)(Text text){
        return new Program(text);
    }
    
    
    ///デバイスに関連付けられているプログラムを表します
    class Program{
    private:
        cl_program _program;
        
    public:
        ///コンストラクタ。ファイルや文字列からプログラムを作製し、ビルドします
        this(Text...)(Text files){
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
            
            _program = clCreateProgramWithSource(   this.outer._context,
                                                    codes.length,
                                                    cps.ptr,
                                                    lengths.ptr,
                                                    &err);
            
            assert(err == CL_SUCCESS);
            
            err = clBuildProgram(   _program,
                                    1,
                                    &(this.outer._deviceId),
                                    null,
                                    null,
                                    null);
            
            assert(err == CL_SUCCESS);
        }
        
        
        ///内部で保持している値を返します
        @property
        cl_program program(){
            return _program;
        }
        
        ///カーネルを取得します
        Kernel kernel(string kernelName){
            return new Kernel(kernelName);
        }
        
        
        ///カーネルを表すためのクラスです
        class Kernel{
        private:
            cl_kernel _kernel;
        
        public:
            ///コンストラクタ
            this(string name){
                cl_errcode err;
                cl_kernel _kernel = clCreateKernel(  this.outer._program,
                                                    toStringz(name),
                                                    &err);
                
                assert(err == CL_SUCCESS);
            }
            
            
            ~this(){
                clReleaseKernel(_kernel);
            }
            
            
            ///内部で保持している値を返します
            @property
            cl_kernel kernel(){
                return _kernel;
            }
            
            
            ///Kernelに実行時のスレッド数と引数とセットします
            void set(SizeT, T...)(Tuple!(SizeT, SizeT)[] dims, T args)if(is(SizeT : size_t)){
                cl_errcode err;
                foreach(idx, U; T){
                    static if(is(U N : Buffer!N)){
                        cl_mem buf = args[idx].buffer;
                        err = clSetKernelArg(_kernel,
                                                    idx,
                                                    size_t.sizeof,
                                                    &buf);
                    }else static if(is(U == Local)){
                        cl_errcode err = clSetKernelArg(_kernel,
                                                    idx,
                                                    args[idx].size,
                                                    null);
                    }else{
                        cl_errcode err = clSetKernelArg(_kernel,
                                                    idx,
                                                    U.sizeof,
                                                    &(args[idx]));
                    }
                        
                    assert(err == CL_SUCCESS);
                }
                
                size_t[] global = array(map!"a[0]"(dims));
                size_t[] local =  array(map!"a[1]"(dims));
                
                err = clEnqueueNDRangeKernel(   this.outer.outer._commandQueue,
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
    
    
    ///arrayからバッファを作って返します
    Buffer!T allocate(T)(T[] array, cl_mem_flags flags = cl_mem_flags.CL_MEM_READ_WRITE){
        return new Buffer!T(array, flags);
    }
    
    
    ///lengthの長さを持つバッファを作成し、かえします。
    Buffer!T allocate(T)(size_t length, cl_mem_flags flags = cl_mem_flags.CL_MEM_READ_WRITE){
        return new Buffer!T(length, flags);
    }
    
    
    ///デバイスのメモリ空間のバッファを表します
    class Buffer(T){
    private:
        cl_mem _buffer;
        size_t _length;
        
    public:
        ///長さを指定してBufferを作ります
        this(size_t length, cl_mem_flags flags = cl_mem_flags.CL_MEM_READ_WRITE){
            cl_errcode err;
            T[] buf = new T[length];
            _buffer = clCreateBuffer(   this.outer._context,
                                        flags,
                                        length * T.sizeof,
                                        buf.ptr,
                                        &err);
            assert(err == CL_SUCCESS);
            _length = length;
        }
        
        
        ///バッファを指定してBufferを作ります
        this(T[] buf, cl_mem_flags flags = cl_mem_flags.CL_MEM_READ_WRITE){
            cl_errcode err;
            
            _buffer = clCreateBuffer( this.outer._context,
                            flags,
                            buf.length * T.sizeof,
                            buf.ptr,
                            &err);
            
            assert(err == CL_SUCCESS);
            _length = buf.length;
        }
        
        
        ///保持している値を返します
        @property
        cl_mem buffer(){
            return _buffer;
        }
        
        ///バッファから値を取得します
        @property
        T[] array(){
            cl_errcode err;
            
            T[] dst = new T[_length];
            
            err = clEnqueueReadBuffer(  this.outer._commandQueue,
                                        _buffer,
                                        CL_TRUE,
                                        0,
                                        _length * T.sizeof,
                                        dst.ptr,
                                        0,
                                        null,
                                        null);
            assert(err == CL_SUCCESS);
            
            return dst;
        }
        
        
        ///バッファの大きさを取得します。バイト値にするにはT.sizeof倍してください
        @property
        size_t length(){
            return _length;
        }
    }
    
    
    ///このデバイスで単純な繰り返し動作を行うようにします
    Buffer!(ElementType!(Unqual!(Range)))
     parallelForeach(string structStr = "", string type = ElementType!(Unqual!(Range)).stringof, Range)
        (Tuple!(size_t, size_t) dim, Range, string repeatBody)if(isInputRange!(Unqual!Range))
    {
        repeatBody = structStr ~ "\n\n__kernel void foreachFunction(__global " ~ type ~ "* range, __global " ~ type ~"* result){\n"
        ~ "size_t i = get_global_id(0);\n" ~
        ~ type ~ " a = range[i], b = result[i];" ~ repeatBody ~ "\n result[i] = b;\n}\n";
        
        auto rangeArray = array(take(range, dim[0]));
        if(rangeArray.length < dim[0]){
            dim[0] = rangeArray.length;
        }
        
        auto input = this.allocate(rangeArray);
        auto result = this.allocate!(ElementType!(typeof(rangeType)))(dim[0]);
        
        this.built(repeatBody).kernel("foreachFunction")([dim], input, result);
        
        return result;
    }
}
