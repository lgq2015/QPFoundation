//
//  QPCrashMonitor.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/4/1.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


@interface QPCrashMonitor : NSObject

/**
 *  返回程序崩溃监控器的共享实例。
 */
+ (instancetype)sharedInstance;

/**
 *  启动程序崩溃监控器的监控行为。
 */
- (void)start;

/**
 *  停止程序崩溃监控器的监控行为。
 */
- (void)stop;

/**
 *  判断当前程序崩溃监控器是否正在监控程序崩溃情况。
 */
- (BOOL)isRunning;

@end


@interface QPCrashMonitor (Concrete)

/**
 *  处理系统发出的程序崩溃异常。默认QPCrashMonitor没有实现该方法，用户可以通过类
 *  别的方式实现自定义的程序崩溃监控行为。
 */
- (void)handle:(NSException *)exception;

@end
