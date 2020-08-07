//
//  NSObject+BlockKeyValueObserving.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/4.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSObject+BlockKeyValueObserving.h>
#import <QPFoundation/NSObject+Association.h>


@interface QPBlockKeyValueObservingObserver : NSObject

@property (nonatomic, unsafe_unretained) id observedObject;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) QPBlockKeyValueObservingBlock observingBlock;

@end


@implementation QPBlockKeyValueObservingObserver

- (void)dealloc
{
    [self.observedObject removeObserver:self forKeyPath:self.keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if (self.observingBlock
        && object == self.observedObject
        && [keyPath isEqualToString:self.keyPath]) {

        if (!self.observingBlock(object, change)) {
            [object removeAssociatedObject:self];
        }
    }
}

@end


@implementation NSObject (BlockKeyValueObserving)

- (void)observeValueForKeyPath:(NSString *)keyPath
                    usingBlock:(QPBlockKeyValueObservingBlock)observingBlock
{
    [self observeValueForKeyPath:keyPath
                         options:NSKeyValueObservingOptionNew
                      usingBlock:observingBlock];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                       options:(NSKeyValueObservingOptions)options
                    usingBlock:(QPBlockKeyValueObservingBlock)observingBlock
{
    QPBlockKeyValueObservingObserver *observer;
    observer = [[QPBlockKeyValueObservingObserver alloc] init];
    observer.observedObject = self;
    observer.keyPath = keyPath;
    observer.observingBlock = observingBlock;

    [self addObserver:observer forKeyPath:keyPath options:options context:nil];
    [self addAssociatedObject:observer];
}

@end
