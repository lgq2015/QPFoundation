//
//  QPFullScreenNavigationViewController.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPFullScreenNavigationController.h>

@implementation QPFullScreenNavigationController

#pragma mark - 初始化及销毁。

- (void)initializeObject
{
    [super initializeObject];
    [super setNavigationBarHidden:YES animated:NO];
    [super setToolbarHidden:YES animated:NO];
}

#pragma mark - 支持将UINavigationController作为页面推至全屏。

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *wrapper = [[UIViewController alloc] init];
        [wrapper addChildViewController:viewController];
        [wrapper.view addSubview:viewController.view];
        [super pushViewController:wrapper animated:animated];
    }
    else {
        [super pushViewController:viewController animated:animated];
    }
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    NSMutableArray *wrappedViewControllers = [NSMutableArray array];

    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *wrapper = [[UIViewController alloc] init];
            [wrapper addChildViewController:viewController];
            [wrapper.view addSubview:viewController.view];
            [wrappedViewControllers addObject:wrapper];
        }
        else {
            [wrappedViewControllers addObject:viewController];
        }
    }

    [super setViewControllers:wrappedViewControllers animated:animated];
}

#pragma mark - 限制用户设置显示全屏导航控制器的导航栏或工具栏。

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!hidden) {
        NSLog(@"[QPFoundation] warning: QPFullScreenNavigationController's "
              @"navigation bar can't be shown.");
    }
}

- (void)setToolbarHidden:(BOOL)toolbarHidden
{
    [self setToolbarHidden:toolbarHidden animated:NO];
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!hidden) {
        NSLog(@"[QPFoundation] warning: QPFullScreenNavigationController's "
              @"tool bar can't be shown.");
    }
}

- (void)setHidesBarsOnSwipe:(BOOL)hidesBarsOnSwipe
{
    // Nothing to do.
}

- (void)setHidesBarsOnTap:(BOOL)hidesBarsOnTap
{
    // Nothing to do.
}

- (void)setHidesBarsWhenKeyboardAppears:(BOOL)hidesBarsWhenKeyboardAppears
{
    // Nothing to do.
}

- (void)setHidesBarsWhenVerticallyCompact:(BOOL)hidesBarsWhenVerticallyCompact
{
    // Nothing to do.
}

- (void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    // Nothing to do.
}

@end
