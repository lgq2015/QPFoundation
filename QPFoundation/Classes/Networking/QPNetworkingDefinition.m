//
//  QPNetworkingDefinition.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/24.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPNetworking.h>


/**
 *  接口定义信息。
 */
QP_DEFINE_STRING(QPNetworkingInterfaceName, @"name");               // 接口名称
QP_DEFINE_STRING(QPNetworkingInterfaceAlias, @"alias");             // 接口别名
QP_DEFINE_STRING(QPNetworkingInterfaceRequest, @"request");         // 请求报文
QP_DEFINE_STRING(QPNetworkingInterfaceResponse, @"response");       // 应答报文
QP_DEFINE_STRING(QPNetworkingInterfaceRequestContentKeyPath,
                 @"request-content-key-path");                      // 请求内容
QP_DEFINE_STRING(QPNetworkingInterfaceResponseContentKeyPath,
                 @"response-content-key-path");                     // 应答内容
QP_DEFINE_STRING(QPNetworkingInterfaceDescription, @"description"); // 描述信息
QP_DEFINE_STRING(QPNetworkingInterfaceFilePath, @"filepath");       // 定义文件
QP_DEFINE_STRING(QPNetworkingInterfaceLineNumber, @"linenumber");   // 定义行号


/**
 *  节点定义信息。
 */
QP_DEFINE_STRING(QPNetworkingNodeName, @"name");                    // 节点名称
QP_DEFINE_STRING(QPNetworkingNodeAlias, @"alias");                  // 节点别名
QP_DEFINE_STRING(QPNetworkingNodeSubfields, @"subfields");          // 子项数组
QP_DEFINE_STRING(QPNetworkingNodeIndependent, @"independent");      // 独立节点
QP_DEFINE_STRING(QPNetworkingNodeCallback, @"callback");            // 回调方法
QP_DEFINE_STRING(QPNetworkingNodeDescription, @"description");      // 描述信息


/**
 *  字段定义信息。
 */
QP_DEFINE_STRING(QPNetworkingFieldName, @"name");                   // 字段名称
QP_DEFINE_STRING(QPNetworkingFieldAlias, @"alias");                 // 字段别名
QP_DEFINE_STRING(QPNetworkingFieldOuterNode, @"outer-node");        // 外部节点
QP_DEFINE_STRING(QPNetworkingFieldConstraint, @"constraint");       // 个数约束
QP_DEFINE_STRING(QPNetworkingFieldSubfields, @"subfields");         // 子项数组
QP_DEFINE_STRING(QPNetworkingFieldCallback, @"callback");           // 回调方法
QP_DEFINE_STRING(QPNetworkingFieldDescription, @"description");     // 描述信息


/**
 *  当前正在定义的节点。仅在协议定义宏内部使用。
 */
__unsafe_unretained QPNetworkingNodeModel *QPNetworkingCurrentNode = nil;


/**
 *  协议定义异常。
 */
QP_DEFINE_KEYNAME(QPNetworkingProtocolException);


/**
 *  协议对象中用于协议定义相关的私有方法。
 */
@interface QPNetworkingProtocol (Definition)

- (void)addInterface:(QPNetworkingInterfaceModel *)interface;
- (void)addNode:(QPNetworkingNodeModel *)node;

@end


#pragma mark - 接口协议上下文。

NSMutableArray *QPNetworkingGetProtocolContextStack()
{
    static NSMutableArray *stack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stack = [[NSMutableArray alloc] init];
    });
    return stack;
}

QPNetworkingProtocol *QPNetworkingGetCurrentProtocolContext()
{
    NSMutableArray *stack = QPNetworkingGetProtocolContextStack();
    return ([stack count] > 0) ? [stack lastObject] : nil;
}

void QPNetworkingPushProtocolContext(QPNetworkingProtocol *context)
{
    NSMutableArray *stack = QPNetworkingGetProtocolContextStack();
    [stack addObject:context];
}

void QPNetworkingPopProtocolContext()
{
    NSMutableArray *stack = QPNetworkingGetProtocolContextStack();
    if ([stack count] > 0) {
        [stack removeLastObject];
    }
}


#pragma mark - 接口协议创建函数。

QPNetworkingInterfaceModel *
QPNetworkingCreateInterface(NSString *name,
                            NSString *alias,
                            QPNetworkingNodeModel *request,
                            NSString *requestContentKeyPath,
                            QPNetworkingNodeModel *response,
                            NSString *responseContentKeyPath,
                            NSString *description,
                            NSString *filePath,
                            NSUInteger lineNumber)
{
    // 校验当前接口的定义参数是否合法。

    if ([name length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The interface(alias:%@)'s name can't be empty.", alias];
    }

    if ([alias length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The interface [%@]'s alias can't be empty.", name];
    }

    if (!request) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The interface [%@]'s request node can't be nil.", name];
    }

    if (!response) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The interface [%@]'s response node can't be nil.", name];
    }

    if ([description length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The interface [%@]'s description can't be empty.", name];
    }

    // 生成当前接口的信息字典。

    QPNetworkingInterfaceModel *interface = [QPNetworkingInterfaceModel dictionary];

    [interface setValue:name forKey:QPNetworkingInterfaceName];
    [interface setValue:alias forKey:QPNetworkingInterfaceAlias];
    [interface setValue:request forKey:QPNetworkingInterfaceRequest];
    [interface setValue:requestContentKeyPath
                 forKey:QPNetworkingInterfaceRequestContentKeyPath];
    [interface setValue:response forKey:QPNetworkingInterfaceResponse];
    [interface setValue:responseContentKeyPath
                 forKey:QPNetworkingInterfaceResponseContentKeyPath];
    [interface setValue:description forKey:QPNetworkingInterfaceDescription];
    [interface setValue:filePath forKey:QPNetworkingInterfaceFilePath];
    [interface setValue:@(lineNumber) forKey:QPNetworkingInterfaceLineNumber];

    if ([[request objectForKey:QPNetworkingNodeDescription] length] <= 0) {
        [request setValue:description forKey:QPNetworkingNodeDescription];
    }

    if ([[response objectForKey:QPNetworkingNodeDescription] length] <= 0) {
        [response setValue:description forKey:QPNetworkingNodeDescription];
    }

    // 将生成的接口定义信息添加到协议上下文中。

    QPNetworkingProtocol *context = QPNetworkingGetCurrentProtocolContext();

    if ([context respondsToSelector:@selector(addInterface:)]) {
        [context addInterface:interface];
    }
    else {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The protocol [%@] don't have `-addInterface:' method.",
         [context name]];
    }

    return interface;
}

QPNetworkingNodeModel *
QPNetworkingCreateIndependentNode(NSString *name,
                                  NSString *alias,
                                  SEL callback,
                                  NSString *description)
{
    // 校验当前节点的定义参数是否合法。

    if ([name length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The independent-node(alias:%@)'s name can't be empty.", alias];
    }

    if ([alias length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The independent-node [%@]'s alias can't be empty.", name];
    }

    if ([description length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The independent-node [%@]'s description can't be empty.", name];
    }

    // 生成当前节点的信息字典。

    QPNetworkingNodeModel *node = [QPNetworkingNodeModel dictionary];
    NSString *selector = callback ? NSStringFromSelector(callback) : nil;

    [node setValue:name forKey:QPNetworkingNodeName];
    [node setValue:alias forKey:QPNetworkingNodeAlias];
    [node setValue:selector forKey:QPNetworkingNodeCallback];
    [node setValue:description forKey:QPNetworkingNodeDescription];
    [node setValue:@(YES) forKey:QPNetworkingNodeIndependent];

    // 将生成的节点定义信息添加到协议上下文中。

    QPNetworkingProtocol *context = QPNetworkingGetCurrentProtocolContext();

    if ([context respondsToSelector:@selector(addNode:)]) {
        [context addNode:node];
    }
    else {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The protocol [%@] don't have `-addNode:' method.",
         [context name]];
    }

    return node;
}

QPNetworkingNodeModel *
QPNetworkingCreateTemporaryNode(NSString *name)
{
    // 校验当前节点的定义参数是否合法。

    if ([name length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The temporary-node's name can't be empty."];
    }

    // 生成当前节点的信息字典。

    QPNetworkingNodeModel *node = [QPNetworkingNodeModel dictionary];

    [node setValue:name forKey:QPNetworkingNodeName];
    [node setValue:name forKey:QPNetworkingNodeAlias];

    return node;
}

QPNetworkingFieldModel *
QPNetworkingCreateField(QPNetworkingFieldModel *parentField,
                        NSString *name,
                        NSString *alias,
                        QPNetworkingNodeModel *outerNode,
                        NSString *constraint,
                        SEL callback,
                        NSString *description)
{
    // 校验当前字段的定义参数是否合法。

    if (!parentField) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field [%@]'s parent field can't be nil.", name];
    }

    if ([name length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field(alias:%@)'s name can't be empty.", alias];
    }

    if ([alias length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field [%@]'s alias can't be empty.", name];
    }

    if ([constraint length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field [%@]'s constraint can't be empty.", name];
    }

    if ([description length] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field [%@]'s description can't be empty.", name];
    }

    if ([(@[@"?", @"+", @"*", @"1"]) containsObject:constraint] <= 0) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field [%@]'s constraint only support:[?+*1].", name];
    }

    // 如果父节点是外部引用节点，则不允许再向其添加子节点。

    if ([parentField objectForKey:QPNetworkingFieldOuterNode]) {
        [NSException raise:QPNetworkingProtocolException format:
         @"[QPFoundation] The field [%@]'s parent field [%@] is an outer-node, "
         @"can't append childs.",
         name, [parentField objectForKey:QPNetworkingFieldName]];
    }

    // 生成当前字段的信息字典。

    QPNetworkingFieldModel *field = [QPNetworkingFieldModel dictionary];
    NSString *selector = callback ? NSStringFromSelector(callback) : nil;

    [field setValue:name forKey:QPNetworkingFieldName];
    [field setValue:alias forKey:QPNetworkingFieldAlias];
    [field setValue:outerNode forKey:QPNetworkingFieldOuterNode];
    [field setValue:constraint forKey:QPNetworkingFieldConstraint];
    [field setValue:selector forKey:QPNetworkingFieldCallback];
    [field setValue:description forKey:QPNetworkingFieldDescription];

    // 向父节点的子项数组添加当前字段。

    NSMutableArray *subfields = [parentField objectForKey:QPNetworkingFieldSubfields];
    if (!subfields) {
        subfields = [NSMutableArray array];
        [parentField setValue:subfields forKey:QPNetworkingFieldSubfields];
    }
    [subfields addObject:field];

    return field;
}
