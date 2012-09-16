module cl4d.exception;
/+
mixin template Cl4dExceptionMixin(alias err, alias errcode, Throw)
{
    if(err != CL_SUCCESS){
        foreach(k; errcode.keys){
            if(k == err)
                throw new Throw(errcode[k]);
        }
    }
}+/