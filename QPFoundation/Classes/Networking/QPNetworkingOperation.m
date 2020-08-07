//
//  QPNetworkingOperation.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/31.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPNetworking.h>


/**
 *  网络请求操作异常。
 */
QP_DEFINE_KEYNAME(QPNetworkingOperationException);


/**
 *  网络请求操作错误域。
 */
QP_DEFINE_KEYNAME(QPNetworkingOperationErrorDomain);


/**
 *  NSOperation相关属性的key。
 */
QP_STATIC_STRING(NSOperationIsReady, @"isReady");
QP_STATIC_STRING(NSOperationIsExecuting, @"isExecuting");
QP_STATIC_STRING(NSOperationIsCancelled, @"isCancelled");
QP_STATIC_STRING(NSOperationIsFinished, @"isFinished");


@implementation QPNetworkingOperation

#pragma mark - 初始化及销毁。

- (void)dealloc
{
    [self removeObserver:self
              forKeyPath:NSOperationIsCancelled];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self
               forKeyPath:NSOperationIsCancelled
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        [self setTimeoutInterval:60.0];
    }
    return self;
}

#pragma mark - KVO消息响应。

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSOperationIsCancelled]) {
        if (self.cancellable && self.cancelled && self.cancellationBlock) {
            QPPerformBlockOnMainThreadAndWait(self.cancellationBlock);
        }
    }
}

#pragma mark - 操作处理流程。

- (void)activate
{
    QPPerformBlockOnMainThreadAndWait(^{
        if (self.initial) {
            self.initial(self);
        }
        self.status = QPNetworkingOperationStatusReady;
    });
}

- (void)start
{
    self.status = QPNetworkingOperationStatusExecuting;
    [self main];
    [self synchronous];
    [self asynchronous];
}

#pragma mark - 处理同步操作。

- (void)synchronous
{
}

#pragma mark - 处理异步操作。

- (void)asynchronous
{
    self.status = QPNetworkingOperationStatusFinished;
}

#pragma mark - 异步状态切换。

- (void)setStatus:(QPNetworkingOperationStatus)status
{
    // 不允许从高层状态切换到低层状态。

    if (_status > status) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] %@'s status can't be change from %d to %d.",
         [self class], (int)_status, (int)status];
    }

    // 如果状态不变，则直接返回。

    if (_status == status) {
        return;
    }

    // 根据切换到的不同状态发出相应的KVO消息。
    // 操作队列侦测发出的KVO消息，并判断当前操作对象的状态，以控制其生命周期。

    switch (status) {
        case QPNetworkingOperationStatusInitial:
            _status = status;
            break;

        case QPNetworkingOperationStatusReady:
            [self willChangeValueForKey:NSOperationIsReady];
            _status = status;
            [self didChangeValueForKey:NSOperationIsReady];
            break;

        case QPNetworkingOperationStatusExecuting:
            [self willChangeValueForKey:NSOperationIsExecuting];
            _status = status;
            [self didChangeValueForKey:NSOperationIsExecuting];
            break;

        case QPNetworkingOperationStatusCancelled:
            _status = status;
            if (!self.cancelled) {
                [self cancel];
            }
            break;

        case QPNetworkingOperationStatusFinished:
            [self willChangeValueForKey:NSOperationIsFinished];
            _status = status;
            [self didChangeValueForKey:NSOperationIsFinished];
            break;

        default:
            _status = status;
            break;
    }
}

#pragma mark - 异步处理支持。

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady
{
    return ([super isReady] && self.status >= QPNetworkingOperationStatusReady);
}

- (BOOL)isExecuting
{
    return (QPNetworkingOperationStatusExecuting == self.status);
}

- (BOOL)isFinished
{
    return (self.status >= QPNetworkingOperationStatusFinished);
}

- (BOOL)isSucceeded
{
    return self.communicationSucceeded && self.verificationPassed;
}

#pragma mark - 报文转换操作。

- (void)handleRequestObjectCallback
{
    if (self.requestObject) {
        self.requestObject = [self.protocol
                              callbackForRequest:self.requestObject
                              atInterface:self.interface
                              withSender:self];
    }
}

- (void)handleRequestObjectToDictionary
{
    if (self.requestObject) {
        self.requestDictionary = [self.protocol
                                  dictionaryForRequest:self.requestObject
                                  atInterface:self.interface];
    }
}

- (void)handleRequestDictionaryToRaw
{
    [NSException raise:QPNetworkingOperationException format:
     @"[QPFoundation] warning: You should override "
     @"`-handleRequestDictionaryToRaw' method to handle requestDictionary to "
     @"requestRaw."];
}

- (void)handleResponseRawToDictionary
{
    [NSException raise:QPNetworkingOperationException format:
     @"[QPFoundation] warning: You should override "
     @"`-handleResponseRawToDictionary' method to handle responseRaw to "
     @"responseDictionary."];
}

- (void)handleResponseDictionaryToObject
{
    if (self.responseDictionary) {
        self.responseObject = [self.protocol
                               responseForDictionary:self.responseDictionary
                               atInterface:self.interface
                               compatibleConstraint:NO];
    }
}

- (void)handleResponseObjectCallback
{
    if (self.responseObject) {
        self.responseObject = [self.protocol
                               callbackForResponse:self.responseObject
                               atInterface:self.interface
                               withSender:self];
    }
}

- (void)handleErrorWithErrorCode:(NSString *)errorCode
                    errorMessage:(NSString *)errorMessage
{
    NSInteger errorCodeValue = [errorCode integerValue];
    NSDictionary *errorInformation = @{@"Error Code":QPNvlString(errorCode, @""),
                                       @"Error Message":QPNvlString(errorMessage, @"")};
    self.error = [NSError errorWithDomain:QPNetworkingOperationErrorDomain
                                     code:errorCodeValue
                                 userInfo:errorInformation];
}

#pragma mark - 应答校验操作。

- (void)verify
{
    [NSException raise:QPNetworkingOperationException format:
     @"[QPFoundation] warning: You should override "
     @"`-verify' method to verify the response what the result is."];
}

#pragma mark - 处理回调操作。

- (void)callback
{
    void (^successBlock)(void) = ^{
        if (self.success) {
            self.success(self);
        }
        self.status = QPNetworkingOperationStatusFinished;
    };

    void (^failureBlock)(void) = ^{
        if (self.failure) {
            self.failure(self);
        }
        self.status = QPNetworkingOperationStatusFinished;
    };

    QPPerformBlockOnMainThreadAndWait(self.succeeded ? successBlock : failureBlock);
}

@end
