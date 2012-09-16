module cl4d.taskmanager;

import cl4d.c.cl;
import cl4d.device;
import cl4d.current;


///デバイスに関連付けられたタスクを管理するクラスです。内部的にはcl_command_queueとcl_eventを操作しています。
class TaskManager{
private:
    Device _device;
    cl_command_queue _queue;
    bool _isParallel = false;

public:
    ///デバイスにタスクプールを作ります
    this(Device device){
        _device = device;
        
        cl_errcode err;
        _queue = clCreateCommandQueue(  _device.clContext,
                                        _device.clDeviceId,
                                        CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE,
                                        &err);
        
        assert(err == CL_SUCCESS);
    }
    
    
    ~this(){
        clReleaseCommandQueue(_queue);
    }
    
    
    ///管理しているタスクを全てflushします
    void flush(){
        clFlush(_queue);
    }
    
    
    ///管理しているタスクが終わるまで待ちます。
    void finish(){
        clFinish(_queue);
    }
    
    
    ///管理しているタスクを全て実行し、終わるまで待ちます
    void execute(){
        this.flush();
        this.finish();
    }
    
    
    ///内部で保持している値を返します
    @property
    cl_command_queue clCommandQueue(){
        return _queue;
    }
    
    
    ///ditto
    @property
    Device device(){
        return _device;
    }
    
    
    ///タスクの同期を行うように設定します。このコマンドはたとえdevice.parallel設定がonでも同期を取るようにします。
    void barrier(){
        cl_errcode err = clEnqueueBarrier(_queue);
        assert(err == CL_SUCCESS);
    }
    

    ///タスクを一つ追加します
    Event addTask(cl_event delegate() task){
        cl_event event = task();
        
        if(!_isParallel)
            barrier();
        
        return new Event(event, this, task);
    }
    
    
    ///ditto
    void addTask(void delegate() task){
        task();
        
        if(!_isParallel)
            barrier();
    }

    
    ///現在の位置のタスクが実行されたに、イベントを発火するようなイベントを返します。
    @property
    Event markCurrentPoint(){
        cl_event event;
        cl_errcode err = clEnqueueMarker(_queue, &event);
        
        assert(err == CL_SUCCESS);
        
        return new Event(event, this, null);
    }
    
    
    ///タスク並列でタスクを実行するようにタスクを設定します。
    void parallel(void delegate() tasks){
        _isParallel = true;
        tasks();
        _isParallel = false;
        barrier();
    }
    
}


///cl_eventを管理するクラスです
class Event{
private:
    cl_event _event;
    TaskManager _manager;
    cl_event delegate() _enqueueBody;

public:
    this(cl_event event, TaskManager manager, cl_event delegate() enqueueBody){
        _event = event;
        _manager = manager;
        _enqueueBody = enqueueBody;
    }
    
    ~this(){
        clReleaseEvent(_event);
    }
    
    
    ///
    @property
    cl_event clEvent(){
        return _event;
    }
    
    
    ///
    @property
    TaskManager taskManager(){
        return _manager;
    }

    
    ///イベント(CL_COMPLETE)が発生した場合に、callBodyを呼び出します
    @property
    void after(void function() callBody){
        cl_errcode err = clSetEventCallback(   _event,
                                    CL_COMPLETE,
                                    &callDelegate,
                                    null);
        assert(err == CL_SUCCESS);
        called[_event] = callBody;
    }
}


//これは酷い…のか…？酷い気がする…
shared void function()[cl_event] called;


extern(System) void callDelegate(cl_event event, cl_int event_command_exec_status, void* user_data){
    synchronized{
        called[event]();
        
        called.remove(event);
    }
}


