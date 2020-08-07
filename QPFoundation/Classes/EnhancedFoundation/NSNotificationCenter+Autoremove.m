//
//  NSNotificationCenter+Autoremove.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/2.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSNotificationCenter+Autoremove.h>
#import <QPFoundation/NSObject+Association.h>
#import <QPFoundation/NSObject+AtDealloc.h>


/**
 *  自动移除消息中心观察者处理回调对象的关联对象名称。
 */
QP_STATIC_KEYNAME(QPAutoremoveObserver);


@implementation NSNotificationCenter (Autoremove)

- (void)autoremoveObserver:(id)notificationObserver
{
    __unsafe_unretained id observer = notificationObserver;

    if (![observer associatedValueForKey:QPAutoremoveObserver]) {
        QPAtDealloc *atDealloc = [QPAtDealloc atDealloc:^{
            [self removeObserver:observer];
        }];
        [observer setAssociatedValue:atDealloc forKey:QPAutoremoveObserver];
    }
}

@end
