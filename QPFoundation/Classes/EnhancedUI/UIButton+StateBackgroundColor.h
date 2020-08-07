//
//  UIButton+StateBackgroundColor.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/2.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIButton (StateBackgroundColor)

- (UIColor *)backgroundColorForState:(UIControlState)state;
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

@end
