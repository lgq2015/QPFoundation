//
//  NSObject+BlockKeyValueObserving.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/4.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  对象属性值变更时的回调Block，返回YES表过继续监听，否则将移除监听。
 */
typedef BOOL (^QPBlockKeyValueObservingBlock)(id observedObject, NSDictionary *change);


@interface NSObject (BlockKeyValueObserving)

- (void)observeValueForKeyPath:(NSString *)keyPath
                    usingBlock:(QPBlockKeyValueObservingBlock)observingBlock;

- (void)observeValueForKeyPath:(NSString *)keyPath
                       options:(NSKeyValueObservingOptions)options
                    usingBlock:(QPBlockKeyValueObservingBlock)observingBlock;

@end
