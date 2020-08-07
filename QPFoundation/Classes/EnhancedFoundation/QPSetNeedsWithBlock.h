//
//  QPSetNeedsWithBlock.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/24.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPNonReentrantLock.h>


/**
 *  在同一个消息循环周期内允许多次触发相同的行为，但只在下一消息循环周期执行一次
 *  该行为，与setNeedsLayout、setNeedsDisplay等方法相类似，可避免程序在同一消息
 *  循环周期内重复做相同工作。
 *
 *  使用示例如下：
 *      - (void)setNeedsDoSomething {
 *          ...
 *          QPSetNeedsWithBlock(^{
 *              <只在下一事件周期执行一次的行为>
 *          });
 *          ...
 *      }
 */
#if __has_feature(objc_arc)

#define QPSetNeedsWithBlock(block) \
    do { \
        QPNonReentrantLock(QPSetNeedsWithBlockLock); \
        if (QPSetNeedsWithBlockLock) { \
            dispatch_async(dispatch_get_main_queue(), ^{ \
                [QPSetNeedsWithBlockLock class]; \
                void (^__block__)(void) = (block); \
                if (__block__) { \
                    __block__(); \
                } \
            }); \
        } \
    } while (0)

#else /* __has_feature(objc_arc) */

#define QPSetNeedsWithBlock(block) \
    do { \
        @autoreleasepool { \
            QPNonReentrantLock(QPSetNeedsWithBlockLock); \
            if (QPSetNeedsWithBlockLock) { \
                dispatch_async(dispatch_get_main_queue(), ^{ \
                    [QPSetNeedsWithBlockLock class]; \
                    void (^__block__)() = (block); \
                    if (__block__) { \
                        __block__(); \
                    } \
                }); \
            } \
        } \
    } while (0)

#endif /* !__has_feature(objc_arc) */
