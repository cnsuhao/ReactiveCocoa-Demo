//
//  TableViewController.m
//  RAC_Demo
//
//  Created by Single on 16/1/16.
//  Copyright © 2016年 single. All rights reserved.
//

#import "TableViewController.h"

#import "ViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController * vc = [segue destinationViewController];
    
    if ([vc isKindOfClass:[ViewController class]]) {
        
        [[(ViewController *)vc subject] sendNext:segue.identifier];
    }
}

@end
