//
//  NSObject+AtDealloc.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/3.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSObject+AtDealloc.h>
#import <QPFoundation/NSObject+Association.h>


#pragma mark - 对象释放的回调处理。

@interface QPAtDealloc ()

@property (nonatomic, copy) QPAtDeallocCallback callback;

@end

@implementation QPAtDealloc

- (void)dealloc
{
    if (_callback) {
        _callback();
    }
}

+ (instancetype)atDealloc:(QPAtDeallocCallback)callback;
{
    __autoreleasing QPAtDealloc *instance;
    instance = [[self alloc] init];
    [instance setCallback:callback];
    return instance;
}

@end

#pragma mark - 添加对象释放时回调。

@implementation NSObject (AtDealloc)

- (void)atDealloc:(QPAtDeallocCallback)callback
{
    [self addAssociatedObject:[QPAtDealloc atDealloc:callback]];
}

@end
