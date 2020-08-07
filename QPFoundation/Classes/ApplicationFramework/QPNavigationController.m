//
//  QPNavigationController.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPNavigationController.h>
#import <QPFoundation/QPApplicationFramework.h>

@implementation QPNavigationController

#pragma mark - 初始化及销毁。

QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithCoder
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithNibName_bundle
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithNavigationBarClass_toolbarClass
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithRootViewController

- (void)initializeObject
{
    QPInitializeApplicationFrameworkObject((QPNavigationBar *)[self navigationBar]);
    QPInitializeApplicationFrameworkObject((QPToolbar *)[self toolbar]);
}

#pragma mark - QPApplicationFrameworkObject

- (void)refreshAppearance
{
    if ([self.navigationBar respondsToSelector:@selector(refreshAppearance)]) {
        [(id)self.navigationBar refreshAppearance];
    }

    if ([self.toolbar respondsToSelector:@selector(refreshAppearance)]) {
        [(id)self.toolbar refreshAppearance];
    }
}

@end
