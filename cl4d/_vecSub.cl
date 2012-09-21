
__kernel void vecSub(__constant int* src1, __constant int* src2, __global int* result){
    int i = get_global_id(0);
    result[i] = src1[i] - src2[i];
}
