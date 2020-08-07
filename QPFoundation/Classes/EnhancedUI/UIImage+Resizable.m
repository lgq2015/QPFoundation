//
//  UIImage+Resizable.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIImage+Resizable.h>

@implementation UIImage (Resizable)

+ (instancetype)resizableImageNamed:(NSString *)name
{
    return [[self imageNamed:name] resizableImage];
}

+ (instancetype)flexibleImageNamed:(NSString *)name
{
    return [[self imageNamed:name] flexibleImage];
}

+ (instancetype)patternImageNamed:(NSString *)name
{
    return [[self imageNamed:name] patternImage];
}

- (UIImage *)resizableImage
{
    CGSize imageSize = [self size];
    return [self
            resizableImageWithCapInsets:
            UIEdgeInsetsMake((imageSize.height - 1) / 2.0,
                             (imageSize.width - 1) / 2.0,
                             (imageSize.height - 1) / 2.0,
                             (imageSize.width - 1) / 2.0)
            resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)flexibleImage
{
    return [self resizableImageWithCapInsets:UIEdgeInsetsZero
                                resizingMode:UIImageResizingModeStretch];
}

- (UIImage *)patternImage
{
    return [self resizableImageWithCapInsets:UIEdgeInsetsZero
                                resizingMode:UIImageResizingModeTile];
}

@end
