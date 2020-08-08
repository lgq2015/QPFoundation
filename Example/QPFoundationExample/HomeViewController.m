//
//  HomeViewController.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "HomeViewController.h"
#import "DEMOProtocolInvokes.h"

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
    QPPanelController *webViewController = [[QPPanelController alloc] init];
    [webViewController setTitle:@"DEMO"];
    [webViewController view];

    UIWebView *webView = [[UIWebView alloc] init];
    [webView setScalesPageToFit:YES];
    [webViewController.contentView addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(webView.superview);
    }];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"DEMOProtocolSummary" withExtension:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

    [webViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)onInvokeButtonClick
{
    SVCQueryUserInformation(^(DEMO_QueryUserInformation_REQ_body *request) {
        request.userid = @"admin";
    }, ^(DEMO_QueryUserInformation_RSP_body *response) {
        for (QPNetworkingType(response.users) user in response.users) {
            NSLog(@"user.userid = %@", user.userid);
            NSLog(@"user.name = %@", user.name);
            NSLog(@"user.age = %@", user.age);
            NSLog(@"user.sex = %@", user.sex);
            NSLog(@"user.birthday = %@", user.birthday);
            NSLog(@"user.register_date = %@", user.register_date);
            NSLog(@"user.remark = %@", user.remark);
        }
    }, nil);
}

@end
