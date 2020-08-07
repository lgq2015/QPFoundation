//
//  UIColor+Conversion.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIColor+Conversion.h>

@implementation UIColor (Conversion)

+ (instancetype)colorWithARGB:(NSUInteger)ARGB
{
    return [[[self class] alloc] initWithARGB:ARGB];
}

+ (instancetype)colorWithRGB:(NSUInteger)RGB
{
    return [[[self class] alloc] initWithRGB:RGB];
}

- (instancetype)initWithARGB:(NSUInteger)ARGB
{
    return [self initWithRed:(CGFloat)(ARGB & 0x00ff0000UL) / 0x00ff0000UL
                       green:(CGFloat)(ARGB & 0x0000ff00UL) / 0x0000ff00UL
                        blue:(CGFloat)(ARGB & 0x000000ffUL) / 0x000000ffUL
                       alpha:(CGFloat)(ARGB & 0xff000000UL) / 0xff000000UL];
}

- (instancetype)initWithRGB:(NSUInteger)RGB
{
    return [self initWithARGB:(RGB | 0xff000000UL)];
}

- (NSUInteger)ARGBValue
{
    CGFloat alpha, red, green, blue;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];

    NSUInteger ARGBValue = 0;
    ARGBValue |= (NSUInteger)(unsigned char)(blue * 255) << 0;
    ARGBValue |= (NSUInteger)(unsigned char)(green * 255) << 8;
    ARGBValue |= (NSUInteger)(unsigned char)(red * 255) << 16;
    ARGBValue |= (NSUInteger)(unsigned char)(alpha * 255) << 24;

    return ARGBValue;
}

- (NSUInteger)RGBValue
{
    return ([self ARGBValue] & 0x00ffffffUL);
}

@end
