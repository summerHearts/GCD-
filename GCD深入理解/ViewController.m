//
//  ViewController.m
//  GCD深入理解
//
//  Created by Kenvin on 16/12/6.
//  Copyright © 2016年 上海方创金融信息服务股份有限公司. All rights reserved.
//

#import "ViewController.h"


#define LOCK(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

static const void * const DispatchMessageDataPrepareSpecificKey = &DispatchMessageDataPrepareSpecificKey;

dispatch_queue_t MessageDataPrepareQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("DataPrepareSpecificKeyMessage.queue", 0);
        dispatch_queue_set_specific(queue, DispatchMessageDataPrepareSpecificKey, (void *)DispatchMessageDataPrepareSpecificKey, NULL);
    });
    return queue;
}

// dispatch_get_specific就是在当前队列中取出标识，线程和队列的关系，所有的动作都是在队列中执行的！
@interface ViewController (){

    dispatch_semaphore_t _lock;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("www.fangchuang.com", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    _lock = dispatch_semaphore_create(1);
    
    for (int i = 0; i < 50; i++) {
        //并列队列的异步执行
        dispatch_group_async(group, concurrentQueue, ^{
            //如果lock的值大于等于1继续执行，否则（-1）返回
            LOCK(
                 NSLog(@">>>>  %d",i);
            );
            
        });
    }
    
    
    //滥用 @synchronized (self) 会很危险，因为所有同步块都会彼此抢夺同一个锁。要是有很多属性都这样写，那么每个属性的同步块都要等待其他所有同步块执行完毕才能执行，其实我们只是想要每个属性各自独立的同步
    //实用@synchronized (self)从某种程度上来说，是线程安全的，但却无法保证访问该对象时是线程安全的。当然，访问属性的操作确实是原子的。实用属性时，确实能从中获取有效值，然而在同一个线程上多次调用getter方法，每次获取的结果却是未必相同的。在两次访问操作之间，可能有其他线程写入了新的值。
    //解决方案： 将写入操作和读取操作放在同一个线程中执行，保证数据同步。
    //dispatch_barrier在并发队列中创建一个同步点，当并发队列中遇到一个 dispatch_barrier时，会延时执行该 dispatch_barrier，等待在 dispatch_barrier之前提交的任务block执行完后才开始执行，之后，并发队列继续执行后续block任务。
    //在队列中，栅栏块必须单独执行，不能和其他块并行。并发队列如果发现接下来要处理的块是个栅栏块，那么就一直等待当前所有并发块都执行完毕，才会单独执行这个栅栏块。等待栅栏块执行过后，再按正常方式继续向下执行。

    for (int i = 0; i< 500000; i++) {
        
        if (i == 499999) {
            dispatch_semaphore_signal(_lock);
            NSLog(@">>>>xxxxxxxx");
        }
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    NSLog(@">>>>xxx");
    
    
    
    dispatch_sync(MessageDataPrepareQueue(), ^{
    
        if (dispatch_get_specific(DispatchMessageDataPrepareSpecificKey)) {
            //当前队列是queue1队列，所以能取到queueKey1对应的值，故而执行
            //后台线程处理宽度计算，处理完之后同步抛到主线程插入
        }else{
           
        }
    });

    //此时遇到tableView 正在滑动就延时操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), MessageDataPrepareQueue(), ^{
        NSLog(@"延时操作");
    });
    
}


@end
