//
//  NSObject+Swizzling.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/1/13.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface NSObject (Swizzling)

/**
 *  互换两个方法的实现体，详见QPExchangeImplementation函数。
 *
 *  @note 建议使用“[当前类类名 class]”代替“[self class]”来调用该方法，以确保
 *        swizzle后替换的行为发生在调用所在的类上，示例如下：
 *        + (void)load
 *        {
 *            [[当前类类名 class] swizzleSelector:@selector(原始方法)
 *                                     toSelector:@selector(替换方法)];
 *        }
 */
+ (void)swizzleSelector:(SEL)originalSelector
             toSelector:(SEL)replacementSelector;

@end
