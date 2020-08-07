//
//  QPNetworking.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/24.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPNetworking.h>


#pragma mark - 网络协议注册列表。

NSMutableDictionary *
QPNetworkingGetRegisteredProtocals()
{
    static NSMutableDictionary *protocals;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocals = [[NSMutableDictionary alloc] init];
    });
    return protocals;
}

QPNetworkingProtocal *
QPNetworkingGetRegisteredProtocal(NSString *name)
{
    return [QPNetworkingGetRegisteredProtocals() objectForKey:name];
}

void
QPNetworkingRegisterProtocal(QPNetworkingProtocal *protocal)
{
    if ([protocal.name length] <= 0) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The protocal(class:%@)'s name can't be empty.",
         [protocal class]];
    }

    NSMutableDictionary *protocals = QPNetworkingGetRegisteredProtocals();
    id registeredProtocal = [protocals objectForKey:protocal.name];

    if (registeredProtocal && registeredProtocal != protocal) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The protocal(class:%@)'s name [%@] is already "
         @"register by the protocal(class:%@).",
         [protocal class], [protocal name], [registeredProtocal class]];
    }

    [protocals setValue:protocal forKey:protocal.name];
}


#pragma mark - 网络请求操作列队。

NSOperationQueue *
QPNetworkingGetOperationQueue()
{
    static NSOperationQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
    });
    return queue;
}

QPNetworkingOperation *
QPNetworkingCommitOperation(NSString *protocalName,
                            NSString *interfaceAlias,
                            void (^initial)(QPNetworkingOperation *operation),
                            void (^success)(QPNetworkingOperation *operation),
                            void (^failure)(QPNetworkingOperation *operation))
{
    // 根据协议名称获取已注册的网络协议对象。

    QPNetworkingProtocal *protocal = QPNetworkingGetRegisteredProtocal(protocalName);
    if (!protocal) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] The protocal [%@] is not registered.",
         protocalName];
    }

    // 根据接口别名获取协议对象中的接口定义信息。

    QPNetworkingInterfaceModel *interface = [protocal interfaceWithAlias:interfaceAlias];
    if (!interface) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] The interface(alias:%@) is not a member of "
         @"the protocal [%@].",
         interfaceAlias, protocalName];
    }

    // 生成网络请求操作对象。

    Class operationClass = NSClassFromString(protocal.operationClassName);
    QPNetworkingOperation *operation = [[operationClass alloc] init];
    if (!operation) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] Create operation instance with class [%@] fail.",
         protocal.operationClassName];
    }

    // 生成请求报文节点对象。

    NSString *className = [protocal classNameForRequestOfInterface:interface];
    Class requestClass = NSClassFromString(className);
    id requestObject = [[requestClass alloc] init];
    if (!requestObject) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] Create request instance with class [%@] fail.",
         className];
    }

    // 初始化网络请求操作对象。

    operation.protocal = protocal;
    operation.interface = interface;

    operation.initial = initial;
    operation.success = success;
    operation.failure = failure;

    operation.requestObject = requestObject;

    // 添加网络请求操作对象到全局的网络请求操作队列。

    NSOperationQueue *queue = QPNetworkingGetOperationQueue();
    [queue addOperation:operation];

    // 在下一个周期的消息循环时激活该网络请求操作。

    dispatch_async(dispatch_get_main_queue(), ^{
        [operation activate];
    });

    return operation;
}
