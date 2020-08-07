//
//  HomeViewController.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Home";
        self.tabBarItem = [[UITabBarItem alloc]
                           initWithTitle:@"Home"
                           image:[UIImage imageNamed:@"tabbar_home"]
                           tag:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // insert code here...
}

@end
