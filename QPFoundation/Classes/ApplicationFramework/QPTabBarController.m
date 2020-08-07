//
//  QPTabBarController.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPTabBarController.h>
#import <QPFoundation/QPApplicationFramework.h>

@implementation QPTabBarController

#pragma mark - 初始化及销毁。

QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithCoder
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithNibName_bundle

- (void)initializeObject
{
    QPInitializeApplicationFrameworkObject((QPTabBar *)[self tabBar]);
}

#pragma mark - 支持初始化或者代码设置选择某个Tab页时可以触发选中委托回调。

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [self triggerDidSelectedViewController];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController
{
    [super setSelectedViewController:selectedViewController];
    [self triggerDidSelectedViewController];
}

- (void)triggerDidSelectedViewController
{
    if (self.selectedViewController && [self.delegate respondsToSelector:
                                        @selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self
                didSelectViewController:self.selectedViewController];
    }
}

#pragma mark - QPApplicationFrameworkObject

- (void)refreshAppearance
{
    if ([self.tabBar respondsToSelector:@selector(refreshAppearance)]) {
        [(id)self.tabBar refreshAppearance];
    }
}

@end
