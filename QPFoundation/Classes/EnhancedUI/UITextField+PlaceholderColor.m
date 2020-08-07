//
//  UITextField+PlaceholderColor.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/2/29.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UITextField+PlaceholderColor.h>
#import <QPFoundation/NSObject+Association.h>
#import <QPFoundation/NSObject+BlockKeyValueObserving.h>
#import <QPFoundation/QPNonReentrantLock.h>


QP_STATIC_KEYNAME(QPTextFieldPlaceholderColor);
QP_STATIC_KEYNAME(QPTextFieldPlaceholderColorIsPlaceholderObserverInstalled);
QP_STATIC_KEYNAME(QPTextFieldPlaceholderColorIsApplyPlaceholderColorLocked);


@implementation UITextField (PlaceholderColor)

#pragma mark - 属性访问相关。

- (UIColor *)placeholderColor
{
    NSString *key = QPTextFieldPlaceholderColor;
    return [self associatedValueForKey:key];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    NSString *key = QPTextFieldPlaceholderColor;
    [self setAssociatedValue:placeholderColor forKey:key];
    [self installPlaceholderObserver];
    [self applyPlaceholderColor];
}

#pragma mark - 业务逻辑相关。

- (void)applyPlaceholderColor
{
    QPNonReentrantLock(applyPlaceholderColorLock);

    if (applyPlaceholderColorLock) {
        NSString *placeholder = [self placeholder];
        UIColor *placeholderColor = [self placeholderColor];

        if (placeholderColor && [placeholder length] > 0) {
            [self setAttributedPlaceholder:
             [[NSAttributedString alloc]
              initWithString:placeholder
              attributes:@{NSForegroundColorAttributeName:placeholderColor}]];
        }
        else {
            [self setPlaceholder:[self placeholder]];
        }
    }
}

- (void)installPlaceholderObserver
{
    NSString *key = QPTextFieldPlaceholderColorIsPlaceholderObserverInstalled;
    BOOL isInstalled = [[self associatedValueForKey:key] boolValue];

    if (!isInstalled) {
        [self
         observeValueForKeyPath:@"placeholder"
         usingBlock:^BOOL(id observedObject, NSDictionary *change) {
             [observedObject applyPlaceholderColor];
             return YES;
         }];

        [self
         observeValueForKeyPath:@"attributedPlaceholder"
         usingBlock:^BOOL(id observedObject, NSDictionary *change) {
             [observedObject applyPlaceholderColor];
             return YES;
         }];

        [self setAssociatedValue:@(YES) forKey:key];
    }
}

@end
