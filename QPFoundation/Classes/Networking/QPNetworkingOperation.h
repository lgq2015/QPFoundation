//
//  QPNetworkingOperation.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/31.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


@class QPNetworkingProtocol;


/**
 *  网络请求操作的状态。
 */
typedef NS_ENUM(NSUInteger, QPNetworkingOperationStatus) {
    QPNetworkingOperationStatusInitial = 0,     // 初始状态。
    QPNetworkingOperationStatusReady,           // 已就绪。
    QPNetworkingOperationStatusExecuting,       // 正在执行。
    QPNetworkingOperationStatusCancelled,       // 已被取消。
    QPNetworkingOperationStatusFinished         // 已经结束。
};


/**
 *  网络请求操作异常。
 */
QP_EXPORT_KEYNAME(QPNetworkingOperationException);


/**
 *  网络请求操作错误域。
 */
QP_EXPORT_KEYNAME(QPNetworkingOperationErrorDomain);


/**
 *  抽象网络请求操作类，应该子类化该类，并根据使用的网络请求方式（同步/异步）重
 *  写asynchronous或synchronous方法，并在适当的时机修改网络请求操作对象的状态为
 *  对应值。
 */
@interface QPNetworkingOperation : NSOperation

@property (nonatomic, strong) QPNetworkingProtocol *protocol;
@property (nonatomic, strong) QPNetworkingInterfaceModel *interface;
@property (nonatomic, assign) QPNetworkingOperationStatus status;

@property (nonatomic, copy) void (^initial)(QPNetworkingOperation *operation);
@property (nonatomic, copy) void (^success)(QPNetworkingOperation *operation);
@property (nonatomic, copy) void (^failure)(QPNetworkingOperation *operation);

@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) BOOL cancellable;
@property (nonatomic, copy) void (^cancellationBlock)(void);

@property (nonatomic, assign, getter=isCommunicationSucceeded) BOOL communicationSucceeded;
@property (nonatomic, assign, getter=isVerificationPassed) BOOL verificationPassed;
@property (nonatomic, assign, readonly, getter=isSucceeded) BOOL succeeded;

@property (nonatomic, strong) id requestObject;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSDictionary *requestDictionary;
@property (nonatomic, strong) NSDictionary *responseDictionary;
@property (nonatomic, strong) id requestRaw;
@property (nonatomic, strong) id responseRaw;
@property (nonatomic, strong) NSError *error;

- (void)activate;
- (void)asynchronous;
- (void)synchronous;

- (void)handleRequestObjectCallback;
- (void)handleRequestObjectToDictionary;
- (void)handleRequestDictionaryToRaw;

- (void)handleResponseRawToDictionary;
- (void)handleResponseDictionaryToObject;
- (void)handleResponseObjectCallback;

- (void)handleErrorWithErrorCode:(NSString *)errorCode
                    errorMessage:(NSString *)errorMessage;

- (void)verify;
- (void)callback;

@end
