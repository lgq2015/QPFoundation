//
//  UIButton+StateBackgroundColor.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/2.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIButton+StateBackgroundColor.h>
#import <QPFoundation/NSObject+Association.h>


QP_STATIC_KEYNAME(QPButtonStateBackgroundColor);


@implementation UIButton (StateBackgroundColor)

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    UIImage *image = [self backgroundImageForState:state];
    return [image associatedValueForKey:QPButtonStateBackgroundColor];
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    if ([color isEqual:[self backgroundColorForState:state]]) {
        return;
    }

    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [image setAssociatedValue:color forKey:QPButtonStateBackgroundColor];
    [self setBackgroundImage:image forState:state];
}

@end
