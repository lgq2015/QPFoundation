//
//  QPNonReentrantLock.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/NSObject+AtDealloc.h>


/**
 *  建立不可重入锁，一般用于避免函数在同一个线程上的递归调用。当不可重入锁未被锁
 *  定状态下进入函数时，不可重入锁将被建立起来，同一个线程后续再调用到相同位置的
 *  代码时，不可重入锁将建立失败，变量name指向的对象将为nil。
 *
 *  使用示例如下：
 *      - (void)doSomething {
 *          QPNonReentrantLock(lock);
 *          if (lock) {
 *              ...
 *          }
 *      }
 *
 *  注意：在MRC环境下调用时，需要使用@autoreleasepool {...}括起来，如下：
 *      - (void)doSomething {
 *          @autoreleasepool {
 *              QPNonReentrantLock(lock);
 *              if (lock) {
 *                  ...
 *              }
 *          }
 *      }
 *
 */
#if __has_feature(objc_arc)

#define QPNonReentrantLock(name) \
    id name = nil;\
    do { \
        static const char __lock__##name = 0; \
        NSString *__lockid__##name = [NSString stringWithFormat: \
            @"QPNonReentrantLock_" # name @"_%p", &__lock__##name]; \
        NSMutableDictionary *__threadDictionary = [[NSThread currentThread] threadDictionary]; \
        if (![__threadDictionary objectForKey:__lockid__##name]) { \
            [__threadDictionary setObject:__lockid__##name forKey:__lockid__##name]; \
            @autoreleasepool { \
                name = [QPAtDealloc atDealloc:^{ \
                    [__threadDictionary setValue:nil forKey:__lockid__##name]; \
                }]; \
            } \
        } \
    } while (0); \
    [name self]

#else /* __has_feature(objc_arc) */

#define QPNonReentrantLock(name) \
    id name = nil;\
    do { \
        static const char __lock__##name = 0; \
        NSString *__lockid__##name = [NSString stringWithFormat: \
            @"QPNonReentrantLock_" # name @"_%p", &__lock__##name]; \
        NSMutableDictionary *__threadDictionary = [[NSThread currentThread] threadDictionary]; \
        if (![__threadDictionary objectForKey:__lockid__##name]) { \
            [__threadDictionary setObject:__lockid__##name forKey:__lockid__##name]; \
            name = [QPAtDealloc atDealloc:^{ \
                [__threadDictionary setValue:nil forKey:__lockid__##name]; \
            }]; \
        } \
    } while (0); \
    [name self]

#endif /* !__has_feature(objc_arc) */
