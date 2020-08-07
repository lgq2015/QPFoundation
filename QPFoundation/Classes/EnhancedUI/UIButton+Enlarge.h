//
//  UIButton+Enlarge.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/2/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIButton (Enlarge)

@property (nonatomic, assign) UIEdgeInsets enlargedInsets;
@property (nonatomic, assign) CGFloat enlargedTop;
@property (nonatomic, assign) CGFloat enlargedLeft;
@property (nonatomic, assign) CGFloat enlargedBottom;
@property (nonatomic, assign) CGFloat enlargedRight;
@property (nonatomic, assign) CGRect enlargedBounds;
@property (nonatomic, assign) CGFloat enlargedRadius;

@end
