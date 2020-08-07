//
//  QPNavigationBar.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPNavigationBar.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/UIColor+Conversion.h>
#import <QPFoundation/UIImage+Resizable.h>

@implementation QPNavigationBar

+ (void)load
{
    QPSetApplicationFrameworkObjectClassCover([UINavigationBar class],
                                              [QPNavigationBar class],
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
    UIColor *backgroundColor = [UIColor colorWithRGB:
                                QPFoundationNavigationBarBackgroundColor];
    UIColor *textColor = [UIColor colorWithRGB:
                          QPFoundationNavigationBarTextColor];

    // 设置导航栏的背景色。

    self.translucent = NO;
    self.barTintColor = backgroundColor;

    // 设置导航项及按钮等的字体颜色。

    self.tintColor = textColor;

    // 设置标题栏字体颜色。

    NSMutableDictionary *textAttributes = [NSMutableDictionary dictionary];
    if (self.titleTextAttributes) {
        [textAttributes addEntriesFromDictionary:self.titleTextAttributes];
    }
    [textAttributes setValue:textColor forKey:NSForegroundColorAttributeName];
    self.titleTextAttributes = textAttributes;

    // 设置导航栏的背景图片。

    UIImage *backgroundImage = QPFoundationNavigationBarBackgroundImage;

    if (!backgroundImage && [QPFoundationNavigationBarBackgroundImageName
                             length] > 0) {
        backgroundImage = [UIImage resizableImageNamed:
                           QPFoundationNavigationBarBackgroundImageName];
    }

    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];

    // 设置返回按钮的指示图片。

    UIImage *backIndicatorImage = QPFoundationNavigationBarBackIndicatorImage;

    if (!backIndicatorImage && [QPFoundationNavigationBarBackIndicatorImageName
                                length] > 0) {
        backIndicatorImage = [UIImage imageNamed:
                              QPFoundationNavigationBarBackIndicatorImageName];
    }

    [self setBackIndicatorImage:backIndicatorImage];
    [self setBackIndicatorTransitionMaskImage:backIndicatorImage];

    // 设置是否显示底部分隔线。

    BOOL isClipsToBounds = !QPFoundationNavigationBarShowsBottomSeparationLine;
    for (UIView *view in self.subviews) {
        [view setClipsToBounds:isClipsToBounds];
    }
}

@end
