//
//  NSString+SizeWithFont.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/1/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSString+SizeWithFont.h>

@implementation NSString (SizeWithFont)

#pragma mark - 字符串宽高度计算。

- (CGFloat)widthWithFontSize:(CGFloat)fontSize
{
    return [self qp_sizeWithFont:[UIFont systemFontOfSize:fontSize]].width;
}

- (CGFloat)heightWithFontSize:(CGFloat)fontSize
{
    return [self qp_sizeWithFont:[UIFont systemFontOfSize:fontSize]].height;
}

- (CGFloat)heightWithFontSize:(CGFloat)fontSize
           constrainedToWidth:(CGFloat)width
{
    return [self qp_sizeWithFont:[UIFont systemFontOfSize:fontSize]
               constrainedToSize:CGSizeMake(width, MAXFLOAT)].height;
}

#pragma mark - iOS 7.0 版本支持。

- (CGSize)qp_sizeWithFont:(UIFont *)font
{
    return [self sizeWithAttributes:@{NSFontAttributeName:font}];
}

- (CGSize)qp_sizeWithFont:(UIFont *)font
        constrainedToSize:(CGSize)size
{
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:font}
                              context:nil].size;
}

- (CGSize)qp_sizeWithFont:(UIFont *)font
        constrainedToSize:(CGSize)size
            lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = lineBreakMode;
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:font,
                                        NSParagraphStyleAttributeName:style}
                              context:nil].size;
}

- (CGSize)qp_drawInRect:(CGRect)rect
               withFont:(UIFont *)font
{
    [self drawInRect:rect
      withAttributes:@{NSFontAttributeName:font}];
    return rect.size;
}

- (CGSize)qp_drawInRect:(CGRect)rect
               withFont:(UIFont *)font
          lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = lineBreakMode;
    [self drawInRect:rect
      withAttributes:@{NSFontAttributeName:font,
                       NSParagraphStyleAttributeName:style}];
    return rect.size;
}

- (CGSize)qp_drawInRect:(CGRect)rect
               withFont:(UIFont *)font
          lineBreakMode:(NSLineBreakMode)lineBreakMode
              alignment:(NSTextAlignment)alignment
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = lineBreakMode;
    style.alignment = alignment;
    [self drawInRect:rect
      withAttributes:@{NSFontAttributeName:font,
                       NSParagraphStyleAttributeName:style}];
    return rect.size;
}

- (CGSize)qp_drawAtPoint:(CGPoint)point
                withFont:(UIFont *)font
{
    [self drawAtPoint:point
       withAttributes:@{NSFontAttributeName:font}];
    return [self qp_sizeWithFont:font];
}

@end
