//
//  UIButton+ImageAndTitleSpacing.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/2/29.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIButton+ImageAndTitleSpacing.h>
#import <QPFoundation/NSObject+Association.h>
#import <QPFoundation/NSObject+BlockKeyValueObserving.h>
#import <QPFoundation/NSLayoutConstraint+SimpleConstraint.h>


QP_STATIC_KEYNAME(QPButtonImageAndTitleSpacing);
QP_STATIC_KEYNAME(QPButtonImageAndTitleSpacingIsImageAndTitleObserverInstalled);
QP_STATIC_KEYNAME(QPButtonImageAndTitleSpacingMinimumWidthConstraint);


@implementation UIButton (ImageAndTitleSpacing)

#pragma mark - 属性访问相关。

- (CGFloat)imageAndTitleSpacing
{
    NSString *key = QPButtonImageAndTitleSpacing;
    return (CGFloat)[[self associatedValueForKey:key] doubleValue];
}

- (void)setImageAndTitleSpacing:(CGFloat)imageAndTitleSpacing
{
    NSString *key = QPButtonImageAndTitleSpacing;
    [self setAssociatedValue:@(imageAndTitleSpacing) forKey:key];
    [self installImageAndTitleObserver];
    [self applyImageAndTitleSpacing];
}

- (NSLayoutConstraint *)minimumWidthConstraint
{
    NSString *key = QPButtonImageAndTitleSpacingMinimumWidthConstraint;
    return [self associatedValueForKey:key];
}

#pragma mark - 业务逻辑相关。

- (void)applyImageAndTitleSpacing
{
    CGFloat spacing = [self imageAndTitleSpacing];
    CGFloat minimumWidth = [self intrinsicContentSize].width + spacing;
    NSLayoutConstraint *minimumWidthConstraint = [self minimumWidthConstraint];

    if (fabs(spacing) < 0.0000001) {
        if (minimumWidthConstraint) {
            [self removeConstraint:minimumWidthConstraint];
        }
    }
    else if (minimumWidthConstraint) {
        minimumWidthConstraint.constant = minimumWidth;
    }
    else {
        minimumWidthConstraint = [NSLayoutConstraint
                                  constraintWithItem:self
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                  toItem:nil
                                  attribute:0
                                  multiplier:1.0
                                  constant:minimumWidth
                                  priority:QPLayoutPriorityHigh];
        [self addConstraint:minimumWidthConstraint];
        [self setAssociatedValue:minimumWidthConstraint
                          forKey:QPButtonImageAndTitleSpacingMinimumWidthConstraint
           withAssociationPolicy:QPAssociationPolicyWeak];
    }

    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

- (void)installImageAndTitleObserver
{
    NSString *key = QPButtonImageAndTitleSpacingIsImageAndTitleObserverInstalled;
    BOOL isInstalled = [[self associatedValueForKey:key] boolValue];

    if (!isInstalled) {
        [self.titleLabel
         observeValueForKeyPath:@"text"
         usingBlock:^BOOL(id observedObject, NSDictionary *change) {
             [(UIButton *)[observedObject superview] applyImageAndTitleSpacing];
             return YES;
         }];

        [self.titleLabel
         observeValueForKeyPath:@"attributedText"
         usingBlock:^BOOL(id observedObject, NSDictionary *change) {
             [(UIButton *)[observedObject superview] applyImageAndTitleSpacing];
             return YES;
         }];

        [self.imageView
         observeValueForKeyPath:@"image"
         usingBlock:^BOOL(id observedObject, NSDictionary *change) {
             [(UIButton *)[observedObject superview] applyImageAndTitleSpacing];
             return YES;
         }];

        [self setAssociatedValue:@(YES) forKey:key];
    }
}

@end
