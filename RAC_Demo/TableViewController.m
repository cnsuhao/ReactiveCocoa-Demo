//
//  TableViewController.m
//  RAC_Demo
//
//  Created by Single on 16/1/16.
//  Copyright © 2016年 single. All rights reserved.
//

#import "TableViewController.h"

#import "StreamViewController.h"
#import "SignalViewController.h"
#import "SubjectViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController * vc = [segue destinationViewController];
    
    if ([vc isKindOfClass:[StreamViewController class]]) {
        
        [[(StreamViewController *)vc subject] sendNext:segue.identifier];
    } else if ([vc isKindOfClass:[SignalViewController class]]) {
        
        
    } else if ([vc isKindOfClass:[SubjectViewController class]]) {
        
        
    }
}

@end
