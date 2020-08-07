//
//  UIButton+Spacing.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/2/29.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIButton (ImageAndTitleSpacing)

@property (nonatomic, assign) CGFloat imageAndTitleSpacing;
@property (nonatomic, weak, readonly) NSLayoutConstraint *minimumWidthConstraint;

@end
