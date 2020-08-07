//
//  NSAttributedString+Size.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/1/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSAttributedString+Size.h>

@implementation NSAttributedString (Size)

- (CGFloat)width
{
    return self.size.width;
}

- (CGFloat)height
{
    return self.size.height;
}

- (CGFloat)heightConstrainedToWidth:(CGFloat)width
{
    return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin
                              context:nil].size.height;
}

@end
