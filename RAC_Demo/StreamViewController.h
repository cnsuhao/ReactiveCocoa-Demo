//
//  StreamViewController.h
//  RAC_Demo
//
//  Created by Single on 16/1/16.
//  Copyright © 2016年 single. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveCocoa.h>

@interface StreamViewController : UIViewController

@property (nonatomic, strong) RACReplaySubject * subject;

@end
