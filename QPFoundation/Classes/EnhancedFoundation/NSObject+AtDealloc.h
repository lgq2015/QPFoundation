//
//  NSObject+AtDealloc.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/3.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  对象释放时回调的block的声明。
 */
typedef void (^QPAtDeallocCallback)(void);


@interface QPAtDealloc : NSObject

/**
 *  构建释放时回调处理对象，当构建出来的QPAtDealloc对象被释放时，会调用callback
 *  指向的回调函数。
 */
+ (instancetype)atDealloc:(QPAtDeallocCallback)callback;

@end


@interface NSObject (AtDealloc)

/**
 *  添加对象释放时的回调处理。
 */
- (void)atDealloc:(QPAtDeallocCallback)callback;

@end
