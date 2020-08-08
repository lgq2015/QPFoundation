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

    // 设置内容视图大小，使之可以被滚动起来。

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2000.0);
    }];

    // 顶部提示信息

    UILabel *topTipLabel = [[UILabel alloc] init];
    [topTipLabel setText:@"Scroll to bottom ..."];
    [topTipLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    [self.contentView addSubview:topTipLabel];
    [topTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.centerX.equalTo(self.contentView);
    }];

    // 底部提示信息

    UILabel *bottomTipLabel = [[UILabel alloc] init];
    [bottomTipLabel setText:@"BOTTOM!"];
    [bottomTipLabel setFont:[UIFont boldSystemFontOfSize:32.0]];
    [self.contentView addSubview:bottomTipLabel];
    [bottomTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.centerX.equalTo(self.contentView);
    }];

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

    // 附加栏

    QPCustomBar *additionCustomBar = [[QPCustomBar alloc] init];
    [additionCustomBar setBackgroundColor:[UIColor colorWithRGB:0xffcccc]];
    [additionCustomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(128.0);
    }];
    [self addBottomCustomBar:additionCustomBar];

    UISwitch *additionSwitch = [[UISwitch alloc] init];
    [additionCustomBar addSubview:additionSwitch];
    [additionSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(additionCustomBar);
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
