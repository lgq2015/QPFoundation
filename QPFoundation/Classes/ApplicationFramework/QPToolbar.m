//
//  QPToolbar.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPToolbar.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/UIColor+Conversion.h>
#import <QPFoundation/UIImage+Resizable.h>

@implementation QPToolbar

+ (void)load
{
    QPSetApplicationFrameworkObjectClassCover([UIToolbar class],
                                              [QPToolbar class],
                                              @[[QPNavigationController class]]);
}

#pragma mark - 初始化及销毁。

QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithCoder
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithFrame

- (void)initializeObject
{
    // Nothing to do.
}

#pragma mark - QPApplicationFrameworkObject

- (void)refreshAppearance
{
    UIColor *backgroundColor = [UIColor colorWithRGB:QPFoundationToolbarBackgroundColor];
    UIColor *textColor = [UIColor colorWithRGB:QPFoundationToolbarTextColor];

    // 设置工具栏的背景色。

    self.translucent = NO;
    self.barTintColor = backgroundColor;

    // 设置按钮等的字体颜色。

    self.tintColor = textColor;

    // 设置工具栏的背景图片。

    UIImage *backgroundImage = QPFoundationToolbarBackgroundImage;

    if (!backgroundImage && [QPFoundationToolbarBackgroundImageName length] > 0) {
        backgroundImage = [UIImage resizableImageNamed:
                           QPFoundationToolbarBackgroundImageName];
    }

    [self setBackgroundImage:backgroundImage
          forToolbarPosition:UIBarPositionAny
                  barMetrics:UIBarMetricsDefault];
}

@end
