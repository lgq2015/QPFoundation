//
//  UIColor+Conversion.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIColor (Conversion)

/**
 *  创建使用ARGB颜色值初始化UIColor对象。
 *
 *  @see -[UIColor initWithARGB:]
 *       -[UIColor initWithRGB:]
 *       +[UIColor colorWithRGB:]
 */
+ (instancetype)colorWithARGB:(NSUInteger)ARGB;

/**
 *  创建使用RGB颜色值初始化的UIColor对象。
 *
 *  @see -[UIColor initWithARGB:]
 *       -[UIColor initWithRGB:]
 *       +[UIColor colorWithARGB:]
 */
+ (instancetype)colorWithRGB:(NSUInteger)RGB;

/**
 *  使用ARGB颜色值初始化UIColor对象。
 *
 *  @param ARGB    ARGB颜色值，从高字节到低字节依次表示“不透明度、红、绿、蓝”。
 *                 下面是一些颜色值的示例：
 *                     0xffffffff - 不透明的白色；
 *                     0xffff0000 - 不透明的红色；
 *                     0x800000ff - 不透明度为50%的蓝色；
 *                     0x00000000 - 完全透明的黑色。
 *
 *  @return 返回初始化完成后UIColor对象。
 *
 *  @see -[UIColor initWithRGB:]
 *       +[UIColor colorWithARGB:]
 *       +[UIColor colorWithRGB:]
 */
- (instancetype)initWithARGB:(NSUInteger)ARGB;

/**
 *  使用RGB颜色值初始化UIColor对象。
 *
 *  @param RGB  RGB颜色值，从高字节到低字节依次表示“未使用、红、绿、蓝”。
 *              下面是一些颜色值的示例：
 *                  0x00ffffff - 白色；
 *                  0x00ff0000 - 红色；
 *                  0x000000ff - 蓝色；
 *                  0x00000000 - 黑色。
 *
 *  @return 返回初始化完成后UIColor对象。
 *
 *  @see -[UIColor initWithARGB:]
 *       +[UIColor colorWithARGB:]
 *       +[UIColor colorWithRGB:]
 */
- (instancetype)initWithRGB:(NSUInteger)RGB;

/**
 *  返回当前颜色的ARGB值。
 */
- (NSUInteger)ARGBValue;

/**
 *  返回当前颜色的RGB值。
 */
- (NSUInteger)RGBValue;

@end
