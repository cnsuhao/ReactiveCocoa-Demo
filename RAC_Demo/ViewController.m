//
//  ViewController.m
//  RAC_Demo
//
//  Created by Single on 16/1/18.
//  Copyright © 2016年 single. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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
    NSLog(@"%@ 用例未实现", NSStringFromSelector(sel));
}

- (RACReplaySubject *)subject
{
    if (!_subject) {
        _subject = [RACReplaySubject subject];
    }
    return _subject;
}

@end
