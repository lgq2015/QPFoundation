//
//  QPTabBar.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/10.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPTabBar.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/UIColor+Conversion.h>
#import <QPFoundation/UIImage+Resizable.h>

@implementation QPTabBar

+ (void)load
{
    QPSetApplicationFrameworkObjectClassCover([UITabBar class],
                                              [QPTabBar class],
                                              @[[QPTabBarController class]]);
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
    UIColor *backgroundColor = [UIColor colorWithRGB:QPFoundationTabBarBackgroundColor];
    UIColor *textColor = [UIColor colorWithRGB:QPFoundationTabBarTextColor];

    // 设置Tab栏的背景色。

    self.translucent = NO;
    self.barTintColor = backgroundColor;

    // 设置Tab项的字体颜色。

    self.tintColor = textColor;

    // 设置Tab栏的背景图片。

    UIImage *backgroundImage = QPFoundationTabBarBackgroundImage;

    if (!backgroundImage && [QPFoundationTabBarBackgroundImageName length] > 0) {
        backgroundImage = [UIImage resizableImageNamed:
                           QPFoundationTabBarBackgroundImageName];
    }

    [self setBackgroundImage:backgroundImage];

    // 设置Tab栏的阴影图片。

    UIImage *shadowImage = QPFoundationTabBarShadowImage;

    if (!shadowImage && [QPFoundationTabBarShadowImageName length] > 0) {
        shadowImage = [UIImage resizableImageNamed:
                       QPFoundationTabBarShadowImageName];
    }

    [self setShadowImage:shadowImage];

    // 设置Tab栏的选中指示图片。

    UIImage *selectionIndicatorImage = QPFoundationTabBarSelectionIndicatorImage;

    if (!selectionIndicatorImage && [QPFoundationTabBarSelectionIndicatorImageName
                                     length] > 0) {
        selectionIndicatorImage = [UIImage imageNamed:
                                   QPFoundationTabBarSelectionIndicatorImageName];
    }

    [self setSelectionIndicatorImage:selectionIndicatorImage];

    // 设置是否显示顶部分隔线。

    BOOL isClipsToBounds = !QPFoundationTabBarShowsTopSeparationLine;
    [self setClipsToBounds:isClipsToBounds];
}

@end
