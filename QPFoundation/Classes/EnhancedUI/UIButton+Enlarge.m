//
//  UIButton+Enlarge.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/2/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIButton+Enlarge.h>
#import <QPFoundation/NSObject+Association.h>


QP_STATIC_KEYNAME(QPButtonEnlargedInsets);


@implementation UIButton (Enlarge)

#pragma mark - 属性访问相关。

- (UIEdgeInsets)enlargedInsets
{
    NSValue *value = [self associatedValueForKey:QPButtonEnlargedInsets];
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setEnlargedInsets:(UIEdgeInsets)enlargedInsets
{
    NSValue *value = [NSValue valueWithUIEdgeInsets:enlargedInsets];
    [self setAssociatedValue:value forKey:QPButtonEnlargedInsets];
}

- (CGFloat)enlargedTop
{
    return self.enlargedInsets.top;
}

- (void)setEnlargedTop:(CGFloat)enlargedTop
{
    UIEdgeInsets enlargedInsets = self.enlargedInsets;
    enlargedInsets.top = enlargedTop;
    self.enlargedInsets = enlargedInsets;
}

- (CGFloat)enlargedLeft
{
    return self.enlargedInsets.left;
}

- (void)setEnlargedLeft:(CGFloat)enlargedLeft
{
    UIEdgeInsets enlargedInsets = self.enlargedInsets;
    enlargedInsets.left = enlargedLeft;
    self.enlargedInsets = enlargedInsets;
}

- (CGFloat)enlargedBottom
{
    return self.enlargedInsets.bottom;
}

- (void)setEnlargedBottom:(CGFloat)enlargedBottom
{
    UIEdgeInsets enlargedInsets = self.enlargedInsets;
    enlargedInsets.bottom = enlargedBottom;
    self.enlargedInsets = enlargedInsets;
}

- (CGFloat)enlargedRight
{
    return self.enlargedInsets.right;
}

- (void)setEnlargedRight:(CGFloat)enlargedRight
{
    UIEdgeInsets enlargedInsets = self.enlargedInsets;
    enlargedInsets.right = enlargedRight;
    self.enlargedInsets = enlargedInsets;
}

- (CGRect)enlargedBounds
{
    UIEdgeInsets enlargedInsets = self.enlargedInsets;
    enlargedInsets.top = -enlargedInsets.top;
    enlargedInsets.left = -enlargedInsets.left;
    enlargedInsets.bottom = -enlargedInsets.bottom;
    enlargedInsets.right = -enlargedInsets.right;
    return UIEdgeInsetsInsetRect(self.bounds, enlargedInsets);
}

- (void)setEnlargedBounds:(CGRect)enlargedBounds
{
    UIEdgeInsets enlargedInsets;
    CGRect bounds = self.bounds;
    enlargedInsets.top = CGRectGetMinY(bounds) - CGRectGetMinY(enlargedBounds);
    enlargedInsets.left = CGRectGetMinY(bounds) - CGRectGetMinY(enlargedBounds);
    enlargedInsets.bottom = CGRectGetMaxX(enlargedBounds) - CGRectGetMaxX(bounds);
    enlargedInsets.right = CGRectGetMaxY(enlargedBounds) - CGRectGetMaxY(bounds);
    self.enlargedInsets = enlargedInsets;
}

- (CGFloat)enlargedRadius
{
    UIEdgeInsets enlargedInsets = self.enlargedInsets;
    CGFloat enlargedRadius = enlargedInsets.top;
    enlargedRadius = MIN(enlargedRadius, enlargedInsets.left);
    enlargedRadius = MIN(enlargedRadius, enlargedInsets.bottom);
    enlargedRadius = MIN(enlargedRadius, enlargedInsets.right);
    return enlargedRadius;
}

- (void)setEnlargedRadius:(CGFloat)enlargedRadius
{
    self.enlargedInsets = UIEdgeInsetsMake(enlargedRadius,
                                           enlargedRadius,
                                           enlargedRadius,
                                           enlargedRadius);
}

#pragma mark - 界面事件响应。

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSValue *value = [self associatedValueForKey:QPButtonEnlargedInsets];
    if (value && CGRectContainsPoint(self.enlargedBounds, point)) {
        return YES;
    }
    return [super pointInside:point withEvent:event];
}

@end
