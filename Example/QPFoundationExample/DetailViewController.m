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

    // 顶部栏

    QPCustomBar *topCustomBar = [[QPCustomBar alloc] init];
    [topCustomBar setBackgroundColor:[UIColor colorWithRGB:0xccffcc]];
    [self addTopCustomBar:topCustomBar];

    UILabel *topLabel = [[UILabel alloc] init];
    [topLabel setText:@"That's a QPCustomBar."];
    [topLabel setTextAlignment:NSTextAlignmentCenter];

    [topCustomBar addSubview:topLabel];
    [topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(topCustomBar);
    }];

    // 底部栏

    QPCustomBar *bottomCustomBar = [[QPCustomBar alloc] init];
    [bottomCustomBar setBackgroundColor:[UIColor colorWithRGB:0xccffcc]];
    [self addBottomCustomBar:bottomCustomBar];

    UILabel *bottomLabel = [[UILabel alloc] init];
    [bottomLabel setText:@"That's another QPCustomBar."];
    [bottomLabel setTextAlignment:NSTextAlignmentCenter];

    [bottomCustomBar addSubview:bottomLabel];
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomCustomBar);
    }];
}

- (void)refreshAppearance
{
    self.view.backgroundColor = [UIColor grayColor];
}

@end
