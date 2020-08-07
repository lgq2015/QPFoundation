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
QPNetworkingGetRegisteredProtocols()
{
    static NSMutableDictionary *protocols;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protocols = [[NSMutableDictionary alloc] init];
    });
    return protocols;
}

QPNetworkingProtocol *
QPNetworkingGetRegisteredProtocol(NSString *name)
{
    return [QPNetworkingGetRegisteredProtocols() objectForKey:name];
}

void
QPNetworkingRegisterProtocol(QPNetworkingProtocol *protocol)
{
    if ([protocol.name length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The protocol(class:%@)'s name can't be empty.",
         [protocol class]];
    }

    NSMutableDictionary *protocols = QPNetworkingGetRegisteredProtocols();
    id registeredProtocol = [protocols objectForKey:protocol.name];

    if (registeredProtocol && registeredProtocol != protocol) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The protocol(class:%@)'s name [%@] is already "
         @"register by the protocol(class:%@).",
         [protocol class], [protocol name], [registeredProtocol class]];
    }

    [protocols setValue:protocol forKey:protocol.name];
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
QPNetworkingCommitOperation(NSString *protocolName,
                            NSString *interfaceAlias,
                            void (^initial)(QPNetworkingOperation *operation),
                            void (^success)(QPNetworkingOperation *operation),
                            void (^failure)(QPNetworkingOperation *operation))
{
    // 根据协议名称获取已注册的网络协议对象。

    QPNetworkingProtocol *protocol = QPNetworkingGetRegisteredProtocol(protocolName);
    if (!protocol) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] The protocol [%@] is not registered.",
         protocolName];
    }

    // 根据接口别名获取协议对象中的接口定义信息。

    QPNetworkingInterfaceModel *interface = [protocol interfaceWithAlias:interfaceAlias];
    if (!interface) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] The interface(alias:%@) is not a member of "
         @"the protocol [%@].",
         interfaceAlias, protocolName];
    }

    // 生成网络请求操作对象。

    Class operationClass = NSClassFromString(protocol.operationClassName);
    QPNetworkingOperation *operation = [[operationClass alloc] init];
    if (!operation) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] Create operation instance with class [%@] fail.",
         protocol.operationClassName];
    }

    // 生成请求报文节点对象。

    NSString *className = [protocol classNameForRequestOfInterface:interface];
    Class requestClass = NSClassFromString(className);
    id requestObject = [[requestClass alloc] init];
    if (!requestObject) {
        [NSException raise:QPNetworkingOperationException format:
         @"[QPFoundation] Create request instance with class [%@] fail.",
         className];
    }

    // 初始化网络请求操作对象。

    operation.protocol = protocol;
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
