//
//  QPLogRecorder.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/4/1.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


@interface QPLogRecorder : NSObject

/**
 *  返回日志记录器的共享实例。
 */
+ (instancetype)sharedInstance;

/**
 *  启动日志记录器的记录行为。
 */
- (void)start;

/**
 *  停止日志记录器的记录行为。
 */
- (void)stop;

/**
 *  判断当前日志记录器是否正在记录日志。
 */
- (BOOL)isRecording;

@end


@interface QPLogRecorder (Concrete)

/**
 *  处理日志记录器记录的日志。
 */
- (void)handle:(NSString *)recordingLog;

@end
