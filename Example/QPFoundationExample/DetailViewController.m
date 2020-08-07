//
//  DetailViewController.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Detail";
        self.tabBarItem = [[UITabBarItem alloc]
                           initWithTitle:@"Detail"
                           image:[UIImage imageNamed:@"tabbar_detail"]
                           tag:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // insert code here...
}

- (void)refreshAppearance
{
    self.view.backgroundColor = [UIColor grayColor];
}

@end
