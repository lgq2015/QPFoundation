//
//  QPCustomBar.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/7.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPCustomBar.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/UIColor+Conversion.h>
#import <QPFoundation/NSLayoutConstraint+SimpleConstraint.h>

@implementation QPCustomBar

#pragma mark - 创建工厂方法。

+ (instancetype)customBarWithView:(UIView *)view
{
    QPCustomBar *customBar = [[QPCustomBar alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [customBar addSubview:view];

    // 在不压缩自定义视图的内容的前提下，让自定义视图的大小与定制栏一致。

    NSNumber *priority = @((UILayoutPriorityDefaultLow + UILayoutPriorityDefaultHigh) / 2.0);
    NSDictionary *views = NSDictionaryOfVariableBindings(customBar, view);
    NSDictionary *metrics = NSDictionaryOfVariableBindings(priority);

    QPVisualFormatBegin(customBar, metrics, views);
    QPVisualFormat(@"H:|-(0@priority,>=0)-[view(<=customBar)]-(0@priority)-|");
    QPVisualFormat(@"V:|-(0@priority,>=0)-[view(<=customBar)]-(0@priority)-|");
    QPVisualFormatEnd();

    // 在定制栏可以完全容纳自定义视图的情况下，将自定义视图放在定制栏的中心位置。

    [customBar addConstraint:
     [NSLayoutConstraint constraintWithItem:view
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:customBar
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0.0
                                   priority:QPLayoutPriorityHigh]];

    [customBar addConstraint:
     [NSLayoutConstraint constraintWithItem:view
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:customBar
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0
                                   constant:0.0
                                   priority:QPLayoutPriorityHigh]];

    return customBar;
}

#pragma mark - 初始化及销毁。

QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithCoder
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithFrame

- (void)initializeObject
{
    // 使用高优先级约束将定制栏的高度限制在大于等于外部参数指定的最小高度上。

    NSNumber *minimum = @(QPFoundationCustomBarMinimumHeight);
    NSNumber *priority = @(QPLayoutPriorityHigh);
    NSDictionary *metrics = NSDictionaryOfVariableBindings(minimum, priority);
    NSDictionary *views = NSDictionaryOfVariableBindings(self);

    QPVisualFormatBegin(self, metrics, views);
    QPVisualFormat(@"V:[self(>=minimum@priority)]");
    QPVisualFormatEnd();
}

#pragma mark - QPApplicationFrameworkObject

- (void)refreshAppearance
{
    self.backgroundColor = [UIColor colorWithRGB:
                            QPFoundationCustomBarBackgroundColor];
}

@end
