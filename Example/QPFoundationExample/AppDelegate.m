//
//  AppDelegate.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/08/07.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "DetailViewController.h"

@implementation AppDelegate

#pragma mark - 初始化应用

- (void)initializePreferences
{
    QPFoundationIsEnablePageNavigationController = YES;
    QPFoundationIsEnableTabBarController = YES;
    QPFoundationIsEnableTabBarControllerSwitchNavigationItem = YES;
    QPFoundationIsPrepushingFrameworkController = YES;

    QPFoundationNavigationBarBackgroundColor = 0x2196f3;
    QPFoundationNavigationBarShowsBottomSeparationLine = NO;

    QPFoundationTabBarBackgroundColor = 0xf5f5f5;
    QPFoundationTabBarTextColor = 0x2196f3;
    QPFoundationTabBarShowsTopSeparationLine = YES;

    QPFoundationCustomBarBackgroundColor = 0x2196f3;
    QPFoundationPanelBackgroundColor = 0xf5f5f9;

    UIColor *cursorColor = [UIColor colorWithRGB:0x2196f3];
    [[UITextField appearance] setTintColor:cursorColor];
    [[UITextView appearance] setTintColor:cursorColor];
}

- (NSArray *)initializeTabBarViewControllers
{
    HomeViewController *home = [[HomeViewController alloc] init];
    DetailViewController *detail = [[DetailViewController alloc] init];
    return @[home, detail];
}

- (QPTabBarController *)loadTabBarController
{
    QPTabBarController *tabBarController = [super loadTabBarController];

    NSArray<UITabBarItem *> *items = [[tabBarController tabBar] items];
    [items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitlePositionAdjustment:UIOffsetMake(0.0, -4.0)];
    }];

    return tabBarController;
}

#pragma mark - 应用入口点

- (void)launching
{
    // insert code here...
}

#pragma mark - 应用出口点

- (void)terminate
{
    // insert code here...
}

@end
