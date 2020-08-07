//
//  NSNotificationCenter+Autoremove.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/2.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface NSNotificationCenter (Autoremove)

/**
 *  当notificationObserver释放（dealloc）时，自动将其从消息中心移除。
 */
- (void)autoremoveObserver:(id)notificationObserver;

@end
