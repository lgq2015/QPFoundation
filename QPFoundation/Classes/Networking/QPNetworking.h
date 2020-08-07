//
//  QPNetworking.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/24.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPNetworkingDefinition.h>
#import <QPFoundation/QPNetworkingProtocol.h>
#import <QPFoundation/QPNetworkingOperation.h>


#pragma mark - 接口协议编程。

/**
 *  相当于keypath所指向节点对应的节点模型类的类型，可用于声明变量等。
 */
#define QPNetworkingType(keypath) \
    __typeof__(keypath##__T__)

/**
 *  相当于keypath所指向节点对应的节点模型类的Class，可用于实例化对象等。
 */
#define QPNetworkingClass(keypath) \
    (keypath##__C__)

/**
 *  实例化keypath所指向节点对应的节点模型类的对象，并赋值给variable变量。
 */
#define QPNetworkingNew(keypath, variable) \
    QPNetworkingType(keypath) variable = \
    ([[QPNetworkingClass(keypath) alloc] init])


#pragma mark - 网络协议注册列表。

/**
 *  获取网络协议注册列表。
 */
FOUNDATION_EXPORT
NSMutableDictionary *
QPNetworkingGetRegisteredProtocols(void);

/**
 *  获取已注册的网络协议。
 */
FOUNDATION_EXPORT
QPNetworkingProtocol *
QPNetworkingGetRegisteredProtocol(NSString *name);

/**
 *  面向框架注册网络协议。
 */
FOUNDATION_EXPORT
void
QPNetworkingRegisterProtocol(QPNetworkingProtocol *protocol);


#pragma mark - 网络请求操作列队。

/**
 *  获取网络请求操作列队。
 */
FOUNDATION_EXPORT
NSOperationQueue *
QPNetworkingGetOperationQueue(void);

/**
 *  提交网络请求操作对象。
 */
FOUNDATION_EXPORT
QPNetworkingOperation *
QPNetworkingCommitOperation(NSString *protocolName,
                            NSString *interfaceAlias,
                            void (^initial)(QPNetworkingOperation *operation),
                            void (^success)(QPNetworkingOperation *operation),
                            void (^failure)(QPNetworkingOperation *operation));
