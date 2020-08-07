//
//  QPLogRecorder.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/4/1.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPLogRecorder.h>


@interface QPLogRecorder ()

@property (nonatomic, assign, getter=isRecording) BOOL recording;
@property (nonatomic, strong) NSFileHandle *originalStderrHandle;
@property (nonatomic, strong) NSPipe *recordingPipe;
@property (nonatomic, strong) NSMutableData *recordingData;

@end


@implementation QPLogRecorder

#pragma mark - 公共方法。

+ (instancetype)sharedInstance
{
    static QPLogRecorder *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - 运行管理相关。

- (void)start
{
    if ([self isRecording]) {
        return;
    }

    // 将当前错误日志输出文件的描述符拷贝一份，用于备份及后面的临时性输出。

    int originalStderrDescriptor = dup(STDERR_FILENO);
    if (originalStderrDescriptor < 0) {
        NSLog(@"[QPFoundation] QPLogRecorder duplicate original stderr "
              @"descriptor failure, errno = [%d].", errno);
        return;
    }

    NSFileHandle *originalHandle = [[NSFileHandle alloc]
                                    initWithFileDescriptor:originalStderrDescriptor
                                    closeOnDealloc:YES];

    // 创建用于截取错误日志输出的管道。

    NSPipe *recordingPipe = [NSPipe pipe];
    if (!recordingPipe) {
        NSLog(@"[QPFoundation] QPLogRecorder create pipe failure.");
        return;
    }

    // 将stderr重定义到日志记录管道。

    NSFileHandle *writingHandle = [recordingPipe fileHandleForWriting];
    if (dup2([writingHandle fileDescriptor], STDERR_FILENO) < 0) {
        NSLog(@"[QPFoundation] QPLogRecorder redirect stderr to recording pipe "
              @"failure, errno = [%d].", errno);
        return;
    }

    // 设置读取stderr输出日志内容的Block。

    NSMutableData *recordingData = [NSMutableData data];
    NSFileHandle *readingHandle = [recordingPipe fileHandleForReading];
    [readingHandle setReadabilityHandler:^(NSFileHandle *handle) {
        NSData *availableData = [handle availableData];
        [recordingData appendData:availableData];
        [originalHandle writeData:availableData];
    }];

    // 记录所有打开的管道、文件描述符等。

    [self setOriginalStderrHandle:originalHandle];
    [self setRecordingPipe:recordingPipe];
    [self setRecordingData:recordingData];
    [self setRecording:YES];
}

- (void)stop
{
    if (![self isRecording]) {
        return;
    }

    NSData *recordingData = self.recordingData;

    // 关闭在stderr上打开的日志记录管道的写文件描述符。

    int originalStderrDescriptor = [self.originalStderrHandle fileDescriptor];
    if (dup2(originalStderrDescriptor, STDERR_FILENO) < 0) {
        close(STDERR_FILENO);
    }

    // 清空并关闭所有打开的管道、文件描述符等。

    [self setOriginalStderrHandle:nil];
    [self setRecordingPipe:nil];
    [self setRecordingData:nil];
    [self setRecording:NO];

    // 提取记录的日志内容，并回调到用户定义的处理方法。

    if ([self respondsToSelector:@selector(handle:)]) {
        NSString *recordingLog = [[NSString alloc]
                                  initWithData:recordingData
                                  encoding:NSUTF8StringEncoding];
        [self handle:recordingLog];
    }
}

@end
