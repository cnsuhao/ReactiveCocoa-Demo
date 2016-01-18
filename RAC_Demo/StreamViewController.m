//
//  StreamViewController.m
//  RAC_Demo
//
//  Created by Single on 16/1/16.
//  Copyright © 2016年 single. All rights reserved.
//

#import "StreamViewController.h"

#import <objc/runtime.h>

@interface StreamViewController ()

@property (weak, nonatomic) IBOutlet UITextField *input;

@property (weak, nonatomic) IBOutlet UILabel *desc;

@property (weak, nonatomic) IBOutlet UIButton *cancel;

@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self)
    [self.subject subscribeNext:^(id x) {
        
        @strongify(self)
        if (!class_respondsToSelector([self class], NSSelectorFromString(x))) {
            class_addMethod([self class], NSSelectorFromString(x), (IMP)addEmptyMethod, "v@:");
        }
        
        IMP imp = class_getMethodImplementation([self class], NSSelectorFromString(x));
        void(* function)(id, SEL) = (void *)imp;
        function(self, NSSelectorFromString(x));
    }];
}

void addEmptyMethod(id self, SEL sel)
{
    NSLog(@"功能未实现");
}

#pragma mark
#pragma mark - fliter/ignore

- (void)filter
{
    /** ---------- fliter ---------- */
    
    /**
     *  过滤
     *
     *  @param value input.text
     *
     *  @return 根据block返回值决定是否sendNext
     */
    RACSignal * fliter = [self.input.rac_textSignal filter:^BOOL(NSString * value) {
        
        if (value.length > 3) {
            NSLog(@"长度校验通过");
            return YES;
        } else {
            NSLog(@"长度校验失败、过滤掉");
            return NO;
        }
    }];
    
    /** ---------- ignore ---------- */
    
    /**
     *  忽略指定value
     */
    RACSignal * ignore = [fliter ignore:@"000000"];
    
    /**
     *  订阅信号、 *Signal只有被订阅后才会sendNext
     *
     *  @param x Signal发出的对象
     *
     *  @return 返回释放对象
     */
    
    @weakify(self)    // 注意避免强强引用
    RACDisposable * disposable = [ignore subscribeNext:^(id x) {
        
        @strongify(self)
        NSLog(@"%@", self.desc.text = [NSString stringWithFormat:@"TextField内容为：%@", x]);
    }];
    
    
    // 取消订阅action
    [[self.cancel rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        self.desc.text = @"取消订阅";
        // dispose后将不再能接收到Signal传出的值
        [disposable dispose];
    }];

}

#pragma mark
#pragma mark - flatten

- (void)flatten
{
    /**
     *  简单对比flatten、flattenMap区别
     *
     *  flatten：合并多个signal
     *  falttenMap：subscribeNext拿到的value为block(value)的subscriber sendNext:newValue中的newValue
     */
    
    
    /** ---------- flatten ---------- */
    
    /**
     *  根据多个源信号源信号创建新信号
     *  value为源信号value
     */
    RACSubject * signal1 = [RACSubject subject];
    RACSubject * signal2 = [RACSubject subject];
    
    RACSignal * signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        
        // 传递信号
        [subscriber sendNext:signal1];
        [subscriber sendNext:signal2];
        
        // 完成
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signalOfSignals释放");
        }];
    }];
    
    RACSignal * flatten = [[signalOfSignals flatten] takeUntil:self.rac_willDeallocSignal];
    
    [flatten subscribeNext:^(NSString *x) {
        NSLog(@"%@", x);
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [signal1 sendNext:@"signal1"];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [signal2 sendNext:@"signal2"];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
        [signal1 sendNext:@"signal1"];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
        [signal1 sendNext:@"signal1"];
    }];
    
    [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{
        [signal2 sendNext:@"signal2"];
    }];
    
    
    /** ---------- flattenMap ---------- */
    
    /**
     *  根据源信号创建新信号 （类似flatten）
     *
     *  @param value 源信号value
     *
     *  @return 新信号
     */
    RACSignal * signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        [[RACScheduler mainThreadScheduler] afterDelay:8 schedule:^{
            [subscriber sendNext:@"flattenMap Value"];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal释放");
        }];
    }] takeUntil:self.rac_willDeallocSignal];
    
    RACSignal * flattenMap = [self.input.rac_textSignal flattenMap:^RACStream *(id value) {
        return signal;
    }];
    
    @weakify(self)
    [flattenMap subscribeNext:^(id x) {
        
        @strongify(self)
        NSLog(@"接收到: %@", self.desc.text = x);
    }];
}

#pragma mark
#pragma mark - map

- (void)map
{
    /** ---------- map ---------- */
    
    // map本质为调用flattenMap 把block(value)的值作为新信号的sendNext的value
    
    /**
     *  值得转换
     *
     *  @param value 源信号value
     *
     *  @return 根据源信号value、加工处理成新value
     */
    RACSignal * map = [[self.input.rac_textSignal distinctUntilChanged] map:^id(id value) {
        return [NSString stringWithFormat:@"map:%@", value];
    }];
    
    [map subscribeNext:^(id x) {
        NSLog(@"map: %@", self.desc.text = x);
    }];
    
    /** ---------- mapReplace ---------- */
    
    /**
     *  无论接受到什么、都替换成指定对象
     */
    RACSignal * mapReplace = [[self.input.rac_textSignal distinctUntilChanged] mapReplace:@"replaceVlaue"];
    
    [mapReplace subscribeNext:^(id x) {
        NSLog(@"mapReplace: %@", x);
    }];
}

#pragma mark
#pragma mark - Skip

- (void)skip
{
    /** ---------- startWith ---------- */
    
    // startWith使用concat实现、concat具体实现在之后介绍
    
    /**
     *  首次sendNext给定对象
     */
    RACSignal * startWith = [self.input.rac_textSignal startWith:@"123"];
    
    [startWith subscribeNext:^(id x) {
        NSLog(@"startWith: %@", x);
    }];
    
    /** ---------- skip ---------- */
    
    /**
     *  跳过第几次
     */
    RACSignal * skip = [self.input.rac_textSignal skip:1];
    
    [skip subscribeNext:^(id x) {
        NSLog(@"skip: %@", x);
    }];
    
    /** ---------- skipUntil ---------- */
    
    /**
     *  一直跳过、知道block返回YES
     */
    RACSignal * skipUntil = [self.input.rac_textSignal skipUntilBlock:^BOOL(id x) {
        return [x isEqualToString:@"000"];
    }];
    
    [skipUntil subscribeNext:^(id x) {
        NSLog(@"skipUntil: %@", x);
    }];
}

- (RACReplaySubject *)subject
{
    if (!_subject) {
        _subject = [RACReplaySubject subject];
    }
    return _subject;
}

@end
