//
//  NSString+SizeWithFont.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/1/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface NSString (SizeWithFont)

- (CGFloat)widthWithFontSize:(CGFloat)fontSize;

- (CGFloat)heightWithFontSize:(CGFloat)fontSize;

- (CGFloat)heightWithFontSize:(CGFloat)fontSize
           constrainedToWidth:(CGFloat)width;

- (CGSize)qp_sizeWithFont:(UIFont *)font;

- (CGSize)qp_sizeWithFont:(UIFont *)font
        constrainedToSize:(CGSize)size;

- (CGSize)qp_sizeWithFont:(UIFont *)font
        constrainedToSize:(CGSize)size
            lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)qp_drawInRect:(CGRect)rect
               withFont:(UIFont *)font;

- (CGSize)qp_drawInRect:(CGRect)rect
               withFont:(UIFont *)font
          lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)qp_drawInRect:(CGRect)rect
               withFont:(UIFont *)font
          lineBreakMode:(NSLineBreakMode)lineBreakMode
              alignment:(NSTextAlignment)alignment;

- (CGSize)qp_drawAtPoint:(CGPoint)point
                withFont:(UIFont *)font;

@end
