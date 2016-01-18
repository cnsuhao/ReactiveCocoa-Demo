//
//  ViewController.h
//  RAC_Demo
//
//  Created by Single on 16/1/18.
//  Copyright © 2016年 single. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <objc/runtime.h>
#import <ReactiveCocoa.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) RACReplaySubject * subject;

@end
