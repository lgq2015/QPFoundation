//
//  UINavigationItem+Assignment.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/17.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UINavigationItem (Assignment)

/**
 *  赋值拷贝方法，将其它导航项赋值给当前对象。
 */
- (void)assignCopy:(UINavigationItem *)other;

@end
