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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 弹窗按钮

    UIButton *popupButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [popupButton setTitle:@"Push a new ViewController" forState:UIControlStateNormal];
    [popupButton setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
    [popupButton setBackgroundColor:[UIColor colorWithRGB:0x339900]
                        forState:UIControlStateNormal];
    [popupButton setClipsToBounds:YES];
    [popupButton.layer setCornerRadius:8.0];
    [self.view addSubview:popupButton];

    [popupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(256.0, 48.0));
        make.center.equalTo(popupButton.superview).with.centerOffset(CGPointMake(0.0, -48.0));
    }];

    [popupButton addTarget:self
                 action:@selector(onPopupButtonClick)
       forControlEvents:UIControlEventTouchUpInside];

    // 调用网络接口按钮

    UIButton *invokeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [invokeButton setTitle:@"Invoke network API" forState:UIControlStateNormal];
    [invokeButton setTitleColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
    [invokeButton setBackgroundColor:[UIColor colorWithRGB:0x339900]
                            forState:UIControlStateNormal];
    [invokeButton setClipsToBounds:YES];
    [invokeButton.layer setCornerRadius:8.0];
    [self.view addSubview:invokeButton];

    [invokeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(256.0, 48.0));
        make.center.equalTo(invokeButton.superview).with.centerOffset(CGPointMake(0.0, 48.0));
    }];

    [invokeButton addTarget:self
                     action:@selector(onInvokeButtonClick)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)onPopupButtonClick
{
    QPPanelController *blank = [[QPPanelController alloc] init];
    blank.title = @"Blank";
    [QPGetPageNavigationController() pushViewController:blank animated:YES];
}

- (void)onInvokeButtonClick
{
    // insert code here...
}

@end
