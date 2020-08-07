//
//  UIImage+Resizable.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIImage (Resizable)

/**
 *  从mainBundle加载指定图片文件并设置中心1x1个像素区域为可自由拉伸的图片对象。
 *
 *  @return 中心1x1个像素区域为可自由拉伸的图片对象。
 *
 *  @see +[UIImage flexibleImageNamed:]
 *       +[UIImage patternImageNamed:]
 */
+ (instancetype)resizableImageNamed:(NSString *)name;

/**
 *  从mainBundle加载指定图片文件并设置为全图可自由拉伸的图片对象。
 *
 *  @return 全图可自由拉伸的图片对象。
 *
 *  @see +[UIImage resizableImageNamed:]
 *       +[UIImage patternImageNamed:]
 */
+ (instancetype)flexibleImageNamed:(NSString *)name;

/**
 *  从mainBundle加载指定图片文件并设置为大小可变图案重复的图片对象。
 *
 *  @return 大小可变图案重复的图片对象。
 *
 *  @see +[UIImage resizableImageNamed:]
 *       +[UIImage flexibleImageNamed:]
 */
+ (instancetype)patternImageNamed:(NSString *)name;

/**
 *  复制当前图片对象并设置中心1x1个像素区域为可自由拉伸的图片对象。
 *
 *  @return 中心1x1个像素区域为可自由拉伸的图片对象。
 *
 *  @see -[UIImage flexibleImage]
 *       -[UIImage patternImage]
 */
- (UIImage *)resizableImage;

/**
 *  复制当前图片对象并设置为全图可自由拉伸的图片对象。
 *
 *  @return 全图可自由拉伸的图片对象。
 *
 *  @see -[UIImage resizableImage]
 *       -[UIImage patternImage]
 */
- (UIImage *)flexibleImage;

/**
 *  复制当前图片对象并设置为大小可变图案重复的图片对象。
 *
 *  @return 大小可变图案重复的图片对象。
 *
 *  @see -[UIImage resizableImage]
 *       -[UIImage flexibleImage]
 */
- (UIImage *)patternImage;

@end
