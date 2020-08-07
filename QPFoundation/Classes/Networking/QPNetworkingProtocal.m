//
//  QPNetworkingProtocal.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/28.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPNetworking.h>


/**
 *  接口调用函数定义信息。
 */
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeName, @"name");         // 接口名称
QP_DEFINE_STRING(QPNetworkingInterfaceEnhancedInvokeName,
                 @"enhanced-name");                                 // 增强版本
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeAlias, @"alias");       // 接口别名
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeRequestClassName,
                 @"request-class-name");                            // 请求报文
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeResponseClassName,
                 @"response-class-name");                           // 应答报文
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeRequestContentKeyPath,
                 @"request-content-key-path");                      // 请求内容
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeResponseContentKeyPath,
                 @"response-content-key-path");                     // 应答内容
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeRequestContentClassName,
                 @"request-content-class-name");                    // 请求内容
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeResponseContentClassName,
                 @"response-content-class-name");                   // 应答内容
QP_DEFINE_STRING(QPNetworkingInterfaceInvokeComments, @"comments"); // 接口注释


/**
 *  节点模型类定义信息。
 */
QP_DEFINE_STRING(QPNetworkingNodeClassName, @"name");               // 模型名称
QP_DEFINE_STRING(QPNetworkingNodeClassProperties, @"properties");   // 属性列表
QP_DEFINE_STRING(QPNetworkingNodeClassComments, @"comments");       // 模型注释


/**
 *  字段属性定义信息。
 */
QP_DEFINE_STRING(QPNetworkingFieldPropertyName, @"name");           // 属性名称
QP_DEFINE_STRING(QPNetworkingFieldPropertyTypeName, @"type-name");  // 属性类型
QP_DEFINE_STRING(QPNetworkingFieldPropertyClassName, @"class-name");// 属性类名
QP_DEFINE_STRING(QPNetworkingFieldPropertyComments, @"comments");   // 属性注释


/**
 *  接口模型类实例与Foundation Objects之间相互转换时发生的异常。
 */
QP_STATIC_KEYNAME(QPNetworkingConversionException);


@interface QPNetworkingProtocal ()

/**
 *  协议名称，用于向框架注册时标识该协议，并且也是默认的根命名空间，用于协议产生
 *  的所有接口调用函数、节点模型类等的前缀。建议使用有意义的缩写，如CRM、ESOP等。
 */
@property (nonatomic, copy) NSString *name;

/**
 *  协议涉及的所有接口定义信息。在initializeInterfaces方法中使用协议定义宏定义接
 *  口协议时，会将定义信息自动添加到该列表，并使用接口别名作为键名。
 */
@property (nonatomic, strong) NSMutableDictionary *interfaces;

/**
 *  协议涉及的所有独立节点定义信息。在initializeInterfaces方法中使用协议定义宏定
 *  义独立节点时，会将定义信息自动添加到该列表，并使用节点别名作为键名。
 */
@property (nonatomic, strong) NSMutableDictionary *nodes;

/**
 *  协议涉及的所有接口的接口调用函数定义信息。通过调用-compile方法后生成该列表，
 *  并使用接口调用函数的函数名作为键名。主要用于生成“<协议类类名>Invokes.h”和
 *  “<协议类类名>Invokes.m”文件时，作为接口调用函数的相关实现代码使用。
 */
@property (nonatomic, strong) NSMutableDictionary *invokes;

/**
 *  协议涉及的所有节点的节点模型类定义信息。通过调用-compile方法后生成该列表，并
 *  使用节点模型类的类名作为键名。主要用于生成“<协议类类名>Classes.h”和“<协议
 *  类类名>Classes.m”文件时，作为节点模型类的相关实现代码使用。
 */
@property (nonatomic, strong) NSMutableDictionary *classes;

/**
 *  根据协议定义信息所生成的所有文件内容。通过调用-compile方法和-link方法后生成。
 *  可以调用-makeToDirectory:方法将这些文件生成到指定目录，并添加到工程中，配合
 *  对应的协议类来完成网络请求作务。
 */
@property (nonatomic, strong) NSMutableDictionary *files;

@end


@implementation QPNetworkingProtocal

#pragma mark - 初始化及销毁。

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {

        // 校验协议参数是否合法。

        if ([name length] <= 0) {
            [NSException raise:QPNetworkingProtocalException format:
             @"[QPFoundation] The protocal(class:%@)'s name can't be empty.",
             [self class]];
        }

        // 初始化协议基本参数。

        self.name = name;
        self.operationClassName = @"UndefinedOperationClass";

        // 初始化协议定义参数。

        self.interfaces = [[NSMutableDictionary alloc] init];
        self.nodes = [[NSMutableDictionary alloc] init];

        // 初始化协议生成参数。

        self.invokes = [[NSMutableDictionary alloc] init];
        self.classes = [[NSMutableDictionary alloc] init];
        self.files = [[NSMutableDictionary alloc] init];

        // 初始化协议涉及的所有接口、独立节点等。

        [self refresh];
    }
    return self;
}

- (void)initializeInterfaces
{
    // Nothing to do.
}

#pragma mark - 属性访问相关。

- (void)setOperationClassName:(NSString *)operationClassName
{
    Class operationClass = NSClassFromString(operationClassName);
    if (operationClass && ![operationClass isSubclassOfClass:[QPNetworkingOperation class]]) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The protocal [%@]'s networking-operation-class "
         @"must be subclass of `%@'.",
         self.name, [QPNetworkingOperation class]];
    }
    _operationClassName = operationClassName;
}

#pragma mark - 接口协议管理。

- (void)refresh
{
    @synchronized(QPNetworkingGetProtocalContextStack()) {
        QPNetworkingPushProtocalContext(self);
        [self.interfaces removeAllObjects];
        [self.nodes removeAllObjects];
        [self.invokes removeAllObjects];
        [self.classes removeAllObjects];
        [self.files removeAllObjects];
        [self initializeInterfaces];
        QPNetworkingPopProtocalContext();
    }
}

- (void)addInterface:(QPNetworkingInterfaceModel *)interface
{
    NSString *name = [interface objectForKey:QPNetworkingInterfaceName];
    NSString *alias = [interface objectForKey:QPNetworkingInterfaceAlias];

    if ([alias length] <= 0) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The interface [%@]'s alias can't be empty.",
         name];
    }

    QPNetworkingInterfaceModel *addedInterface;
    addedInterface = [self.interfaces objectForKey:alias];

    if (addedInterface) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The interface [%@]'s alias [%@] is already "
         @"register by the interface [%@].",
         name, alias, [addedInterface objectForKey:QPNetworkingInterfaceName]];
    }

    [self.interfaces setValue:interface forKey:alias];
}

- (void)addNode:(QPNetworkingNodeModel *)node
{
    NSString *name = [node objectForKey:QPNetworkingNodeName];
    NSString *alias = [node objectForKey:QPNetworkingNodeAlias];
    BOOL isIndependent = [[node objectForKey:QPNetworkingNodeIndependent] boolValue];

    if ([alias length] <= 0) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The node [%@]'s alias can't be empty.",
         name];
    }

    QPNetworkingNodeModel *addedNode = [self.nodes objectForKey:alias];

    if (addedNode) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The node [%@]'s alias [%@] is already "
         @"register by the node [%@].",
         name, alias, [addedNode objectForKey:QPNetworkingNodeName]];
    }

    if (!isIndependent) {
        [NSException raise:QPNetworkingProtocalException format:
         @"[QPFoundation] The node [%@] is a temporary-node, "
         @"only independent-node can be immediate member of protocal.",
         name];
    }

    [self.nodes setValue:node forKey:alias];
}

#pragma mark - 接口协议查询。

- (NSArray *)allInterfaceAliases
{
    return [self.interfaces allKeys];
}

- (NSArray *)allNodeAliases
{
    return [self.nodes allKeys];
}

- (QPNetworkingInterfaceModel *)interfaceWithAlias:alias
{
    return [self.interfaces objectForKey:alias];
}

- (QPNetworkingNodeModel *)nodeWithAlias:alias
{
    return [self.nodes objectForKey:alias];
}

#pragma mark - 接口协议编程。

- (NSString *)nameSpace
{
    // 默认使用协议名称作为根命名空间。

    return self.name;
}

- (NSString *)nameSpaceForInterface:(QPNetworkingInterfaceModel *)interface
{
    // 默认使用根命名空间为接口命名空间命名。

    return [self nameSpaceForInterface:interface
                         withNameSpace:[self nameSpace]];
}

- (NSString *)nameSpaceForInterface:(QPNetworkingInterfaceModel *)interface
                      withNameSpace:(NSString *)nameSpace
{
    // 默认使用接口的调用函数名作为命名空间。

    return [self invokeNameForInterface:interface
                          withNameSpace:nameSpace];
}

- (NSString *)nameSpaceForNode:(QPNetworkingNodeModel *)node
                 withNameSpace:(NSString *)nameSpace
{
    // 默认使用节点的模型类类名作为命名空间。

    return [self classNameForNode:node
                    withNameSpace:nameSpace];
}

- (NSString *)nameSpaceForKey:(NSString *)key
                       atNode:(QPNetworkingNodeModel *)node
                withNameSpace:(NSString *)nameSpace
{
    // 默认使用节点的模型类类名作为命名空间。

    return [self classNameForKey:key
                          atNode:node
                   withNameSpace:nameSpace];
}

- (NSString *)nameSpaceForKeyPath:(NSString *)keyPath
                           atNode:(QPNetworkingNodeModel *)node
                    withNameSpace:(NSString *)nameSpace
{
    // 默认使用节点的模型类类名作为命名空间。

    return [self classNameForKeyPath:keyPath
                              atNode:node
                       withNameSpace:nameSpace];
}

- (NSString *)operationName
{
    return [self operationClassName];
}

- (NSString *)invokeNameForInterface:(QPNetworkingInterfaceModel *)interface
{
    return [self invokeNameForInterface:interface
                          withNameSpace:[self nameSpace]];
}

- (NSString *)invokeNameForInterface:(QPNetworkingInterfaceModel *)interface
                       withNameSpace:(NSString *)nameSpace
{
    NSString *alias = [interface objectForKey:QPNetworkingInterfaceAlias];

    // 使用“命名空间_接口别名”作为接口的调用函数名。

    if (alias && [nameSpace length] > 0) {
        alias = [NSString stringWithFormat:@"%@_%@", nameSpace, alias];
    }

    return alias;
}

- (NSString *)enhancedInvokeNameForInterface:(QPNetworkingInterfaceModel *)interface
{
    return [self enhancedInvokeNameForInterface:interface
                                  withNameSpace:[self nameSpace]];
}

- (NSString *)enhancedInvokeNameForInterface:(QPNetworkingInterfaceModel *)interface
                               withNameSpace:(NSString *)nameSpace
{
    NSString *invokeName = [self invokeNameForInterface:interface
                                          withNameSpace:nameSpace];

    invokeName = [invokeName stringByAppendingString:@"X"];

    return invokeName;
}

- (NSString *)classNameForRequestOfInterface:(QPNetworkingInterfaceModel *)interface
{
    return [self classNameForNode:[self nodeForRequestOfInterface:interface]
                    withNameSpace:[self nameSpaceForInterface:interface]];
}

- (NSString *)classNameForResponseOfInterface:(QPNetworkingInterfaceModel *)interface
{
    return [self classNameForNode:[self nodeForResponseOfInterface:interface]
                    withNameSpace:[self nameSpaceForInterface:interface]];
}

- (NSString *)classNameForRequestOfInterface:(QPNetworkingInterfaceModel *)interface
                               withNameSpace:(NSString *)nameSpace
{
    return [self classNameForNode:[self nodeForRequestOfInterface:interface]
                    withNameSpace:nameSpace];
}

- (NSString *)classNameForResponseOfInterface:(QPNetworkingInterfaceModel *)interface
                                withNameSpace:(NSString *)nameSpace
{
    return [self classNameForNode:[self nodeForResponseOfInterface:interface]
                    withNameSpace:nameSpace];
}

- (NSString *)classNameForNode:(QPNetworkingNodeModel *)node
                 withNameSpace:(NSString *)nameSpace
{
    NSString *alias = [node objectForKey:QPNetworkingNodeAlias];
    BOOL isIndependent = [[node objectForKey:QPNetworkingNodeIndependent] boolValue];

    // 如果是独立节点，则使用协议的根命名空间。

    if (isIndependent) {
        nameSpace = [self nameSpace];
    }

    // 使用“命名空间_节点别名”作为节点的模型类类名。

    if (alias && [nameSpace length] > 0) {
        alias = [NSString stringWithFormat:@"%@_%@", nameSpace, alias];
    }

    return alias;
}

- (NSString *)classNameForField:(QPNetworkingFieldModel *)field
                  withNameSpace:(NSString *)nameSpace
{
    // 返回或构造当前字段对应的节点定义信息。

    QPNetworkingNodeModel *node = [self nodeForField:field];

    // 如果当前字段为普通字段，则直接返回nil即可，否则返回节点的类名。

    return node ? ([self classNameForNode:node withNameSpace:nameSpace]) : nil;
}

- (NSString *)classNameForKey:(NSString *)key
                       atNode:(QPNetworkingNodeModel *)node
                withNameSpace:(NSString *)nameSpace
{
    // 返回或构造目标字段对应的节点定义信息及命名空间。

    nameSpace = [self nameSpaceForNode:node withNameSpace:nameSpace];
    node = [self nodeForKey:key atNode:node];

    // 如果目标字段为普通字段，则直接返回nil即可，否则返回目标节点的类名。

    return node ? ([self classNameForNode:node withNameSpace:nameSpace]) : nil;
}

- (NSString *)classNameForKeyPath:(NSString *)keyPath
                           atNode:(QPNetworkingNodeModel *)node
                    withNameSpace:(NSString *)nameSpace
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];

    // 遍历key-path，从左往右逐个取出其对应的节点定义信息及命名空间。

    for (NSString *key in keys) {
        nameSpace = [self nameSpaceForNode:node withNameSpace:nameSpace];
        node = [self nodeForKey:key atNode:node];
    }

    // 如果目标字段为普通字段，则直接返回nil即可，否则返回目标节点的类名。

    return node ? ([self classNameForNode:node withNameSpace:nameSpace]) : nil;
}

- (NSString *)typeNameForField:(QPNetworkingFieldModel *)field
                 withNameSpace:(NSString *)nameSpace
{
    // 如果当前字段的约束支持多个，则直接返回可变数组类型。

    NSString *constraint = [field objectForKey:QPNetworkingFieldConstraint];

    if ([constraint isEqualToString:@"+"]
        || [constraint isEqualToString:@"＋"]
        || [constraint isEqualToString:@"*"]
        || [constraint isEqualToString:@"＊"]) {
        return NSStringFromClass([NSMutableArray class]);
    }

    // 如果当前字段为节点字段，则直接返回节点对应的模型类类名。

    NSString *className = [self classNameForField:field withNameSpace:nameSpace];

    if ([className length] > 0) {
        return className;
    }

    // 如果当前字段为普通字段，则直接返回字符串类型。

    return NSStringFromClass([NSString class]);
}

- (NSString *)typeNameForKey:(NSString *)key
                      atNode:(QPNetworkingNodeModel *)node
               withNameSpace:(NSString *)nameSpace
{
    // 获取目标字段的定义信息及命名空间。

    nameSpace = [self nameSpaceForNode:node withNameSpace:nameSpace];
    QPNetworkingFieldModel *field = [self fieldForKey:key atNode:node];

    // 返回目标字段的类型名称。

    return field ? ([self typeNameForField:field withNameSpace:nameSpace]) : nil;
}

- (NSString *)typeNameForKeyPath:(NSString *)keyPath
                          atNode:(QPNetworkingNodeModel *)node
                   withNameSpace:(NSString *)nameSpace
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    NSUInteger count = [keys count];

    if (count <= 0) {
        return nil;
    }

    // 取出目标字段的别名，以及父字段的key-path。

    NSString *alias = [keys lastObject];
    keys = [keys subarrayWithRange:NSMakeRange(0, count - 1)];

    // 遍历key-path，从左往右逐个取出其对应的节点定义信息及命名空间。

    for (NSString *key in keys) {
        nameSpace = [self nameSpaceForNode:node withNameSpace:nameSpace];
        node = [self nodeForKey:key atNode:node];
    }

    // 如果父字段为普通字段，则直接返回nil即可，否则返回目标节点的类型名称。

    return node ? ([self typeNameForKey:alias atNode:node withNameSpace:nameSpace]) : nil;
}

- (QPNetworkingNodeModel *)nodeForRequestOfInterface:(QPNetworkingInterfaceModel *)interface
{
    return [interface objectForKey:QPNetworkingInterfaceRequest];
}

- (QPNetworkingNodeModel *)nodeForResponseOfInterface:(QPNetworkingInterfaceModel *)interface
{
    return [interface objectForKey:QPNetworkingInterfaceResponse];
}

- (QPNetworkingNodeModel *)nodeForField:(QPNetworkingFieldModel *)field
{
    // 提取字段定义信息。

    NSString *name = [field objectForKey:QPNetworkingFieldName];
    NSString *alias = [field objectForKey:QPNetworkingFieldAlias];
    NSMutableArray *subfields = [field objectForKey:QPNetworkingFieldSubfields];
    QPNetworkingNodeModel *outerNode = [field objectForKey:QPNetworkingFieldOuterNode];
    NSString *description = [field objectForKey:QPNetworkingFieldDescription];

    // 如果当前字段有子节点，则直接将其作为节点返回。

    if ([subfields count] > 0) {
        return (QPNetworkingNodeModel *)field;
    }

    // 如果当前字段为普通字段，则直接返回nil即可。

    if (!outerNode) {
        return nil;
    }

    // 如果关联的外部节点是独立节点，则直接返回该独立节点。

    if ([[outerNode objectForKey:QPNetworkingNodeIndependent] boolValue]) {
        return outerNode;
    }

    // 当前关联的外部节点是临时节点，需要构造一个具体的节点返回。

    QPNetworkingNodeModel *node = [QPNetworkingNodeModel dictionary];
    subfields = [outerNode objectForKey:QPNetworkingNodeSubfields];

    [node setValue:name forKey:QPNetworkingNodeName];
    [node setValue:alias forKey:QPNetworkingNodeAlias];
    [node setValue:subfields forKey:QPNetworkingNodeSubfields];
    [node setValue:@(NO) forKey:QPNetworkingNodeIndependent];
    [node setValue:description forKey:QPNetworkingNodeDescription];

    return node;
}

- (QPNetworkingNodeModel *)nodeForKey:(NSString *)key
                               atNode:(QPNetworkingNodeModel *)node
{
    return [self nodeForField:[self fieldForKey:key atNode:node]];
}

- (QPNetworkingNodeModel *)nodeForKeyPath:(NSString *)keyPath
                                   atNode:(QPNetworkingNodeModel *)node
{
    return [self nodeForField:[self fieldForKeyPath:keyPath atNode:node]];
}

- (QPNetworkingFieldModel *)fieldForKey:(NSString *)key
                                 atNode:(QPNetworkingNodeModel *)node
{
    NSMutableArray *subfields = [node objectForKey:QPNetworkingNodeSubfields];

    for (QPNetworkingFieldModel *field in subfields) {
        NSString *alias = [field objectForKey:QPNetworkingFieldAlias];
        if (alias && [key isEqualToString:alias]) {
            return field;
        }
    }

    return nil;
}

- (QPNetworkingFieldModel *)fieldForKeyPath:(NSString *)keyPath
                                     atNode:(QPNetworkingNodeModel *)node
{
    NSArray *keys = [keyPath componentsSeparatedByString:@"."];
    NSUInteger count = [keys count];

    if (count <= 0) {
        return nil;
    }

    // 取出目标字段的别名，以及父字段的key-path。

    NSString *alias = [keys lastObject];
    keys = [keys subarrayWithRange:NSMakeRange(0, count - 1)];

    // 遍历key-path，从左往右逐个取出其对应的节点定义信息。

    for (NSString *key in keys) {
        node = [self nodeForKey:key atNode:node];
    }

    // 如果父字段为普通字段，则直接返回nil即可，否则返回目标字段的定义信息。

    return node ? ([self fieldForKey:alias atNode:node]) : nil;
}

#pragma mark - 接口协议编译。

- (void)compile
{
    NSString *nameSpace = [self nameSpace];

    // 清空之前的编译结果。

    [self.invokes removeAllObjects];
    [self.classes removeAllObjects];
    [self.files removeAllObjects];

    // 编译所有独立节点，产生对应的模型类定义信息。

    NSArray *allNodes = [self.nodes allValues];
    for (QPNetworkingNodeModel *node in allNodes) {
        [self compileNode:node withNameSpace:nameSpace];
    }

    // 编译所有接口协议，产生对应的接口调用函数及节点模型类定义信息。

    NSArray *allInterfaces = [self.interfaces allValues];
    for (QPNetworkingInterfaceModel *interface in allInterfaces) {
        [self compileInterface:interface withNameSpace:nameSpace];
    }
}

- (QPNetworkingInterfaceInvokeModel *)compileInterface:(QPNetworkingInterfaceModel *)interface
                                         withNameSpace:(NSString *)nameSpace
{
    QPNetworkingInterfaceInvokeModel *interfaceInvoke;

    // 提取接口定义信息。

    NSString *alias = [interface objectForKey:QPNetworkingInterfaceAlias];
    QPNetworkingNodeModel *request = [interface objectForKey:
                                      QPNetworkingInterfaceRequest];
    QPNetworkingNodeModel *response = [interface objectForKey:
                                       QPNetworkingInterfaceResponse];
    NSString *requestContentKeyPath = [interface objectForKey:
                                       QPNetworkingInterfaceRequestContentKeyPath];
    NSString *responseContentKeyPath = [interface objectForKey:
                                        QPNetworkingInterfaceResponseContentKeyPath];
    NSString *description = [interface objectForKey:
                             QPNetworkingInterfaceDescription];

    // 生成请求/应答报文节点对应的模型类的命名空间。

    nameSpace = [self nameSpaceForInterface:interface withNameSpace:nameSpace];

    // 编译请求/应答报文节点，产生对应的模型类定义信息。

    [self compileNode:request withNameSpace:nameSpace];
    [self compileNode:response withNameSpace:nameSpace];

    // 生成当前接口的调用函数名、请求/应答报文类名、请求/应答内容类名等。

    NSString *invokeName = [self invokeNameForInterface:interface];
    NSString *enhancedInvokeName = [self enhancedInvokeNameForInterface:interface];
    NSString *requestClassName = [self classNameForRequestOfInterface:interface
                                                        withNameSpace:nameSpace];
    NSString *responseClassName = [self classNameForResponseOfInterface:interface
                                                          withNameSpace:nameSpace];

    NSString *requestContentClassName = nil;
    NSString *responseContentClassName = nil;

    if ([requestContentKeyPath length] > 0) {
        requestContentClassName = [self classNameForKeyPath:requestContentKeyPath
                                                     atNode:request
                                              withNameSpace:nameSpace];
    }

    if ([responseContentKeyPath length] > 0) {
        responseContentClassName = [self classNameForKeyPath:responseContentKeyPath
                                                      atNode:response
                                               withNameSpace:nameSpace];
    }

    // 生成当前接口的调用函数定义信息。

    interfaceInvoke = [[QPNetworkingInterfaceInvokeModel alloc] init];
    [interfaceInvoke setValue:invokeName
                       forKey:QPNetworkingInterfaceInvokeName];
    [interfaceInvoke setValue:enhancedInvokeName
                       forKey:QPNetworkingInterfaceEnhancedInvokeName];
    [interfaceInvoke setValue:alias
                       forKey:QPNetworkingInterfaceInvokeAlias];
    [interfaceInvoke setValue:requestClassName
                       forKey:QPNetworkingInterfaceInvokeRequestClassName];
    [interfaceInvoke setValue:responseClassName
                       forKey:QPNetworkingInterfaceInvokeResponseClassName];
    [interfaceInvoke setValue:requestContentKeyPath
                       forKey:QPNetworkingInterfaceInvokeRequestContentKeyPath];
    [interfaceInvoke setValue:responseContentKeyPath
                       forKey:QPNetworkingInterfaceInvokeResponseContentKeyPath];
    [interfaceInvoke setValue:requestContentClassName
                       forKey:QPNetworkingInterfaceInvokeRequestContentClassName];
    [interfaceInvoke setValue:responseContentClassName
                       forKey:QPNetworkingInterfaceInvokeResponseContentClassName];
    [interfaceInvoke setValue:description
                       forKey:QPNetworkingInterfaceInvokeComments];
    [self.invokes setValue:interfaceInvoke forKey:invokeName];

    return interfaceInvoke;
}

- (QPNetworkingNodeClassModel *)compileNode:(QPNetworkingNodeModel *)node
                              withNameSpace:(NSString *)nameSpace
{
    QPNetworkingNodeClassModel *nodeClass;

    // 提取节点定义信息。

    NSMutableArray *subfields = [node objectForKey:QPNetworkingNodeSubfields];
    NSString *description = [node objectForKey:QPNetworkingNodeDescription];

    // 生成当前节点的类名以及子节点对应的模型类的命名空间。

    NSString *className;
    className = [self classNameForNode:node withNameSpace:nameSpace];
    nameSpace = [self nameSpaceForNode:node withNameSpace:nameSpace];

    // 如果已经编译过该节点，则直接返回编译结果。

    nodeClass = [self.classes objectForKey:className];
    if (nodeClass) {
        return nodeClass;
    }

    // 编译当前节点的所有子节点，产生对应的字段属性定义信息。

    NSMutableArray *properties = [[NSMutableArray alloc] init];
    for (QPNetworkingFieldModel *field in subfields) {
        [properties addObject:[self compileField:field withNameSpace:nameSpace]];
    }

    // 生成当前节点对应的模型类定义信息。

    nodeClass = [[QPNetworkingNodeClassModel alloc] init];
    [nodeClass setValue:className forKey:QPNetworkingNodeClassName];
    [nodeClass setValue:properties forKey:QPNetworkingNodeClassProperties];
    [nodeClass setValue:description forKey:QPNetworkingNodeClassComments];
    [self.classes setValue:nodeClass forKey:className];

    return nodeClass;
}

- (QPNetworkingFieldPropertyModel *)compileField:(QPNetworkingFieldModel *)field
                                   withNameSpace:(NSString *)nameSpace
{
    QPNetworkingFieldPropertyModel *fieldProperty;

    // 提取字段定义信息。

    NSString *alias = [field objectForKey:QPNetworkingFieldAlias];
    NSString *description = [field objectForKey:QPNetworkingFieldDescription];

    // 取得当前字段的类型名称。

    NSString *typeName = [self typeNameForField:field withNameSpace:nameSpace];
    NSString *className = [self classNameForField:field withNameSpace:nameSpace];

    // 如果当前字段为节点字段，则先按节点进行编译。

    QPNetworkingNodeModel *node = [self nodeForField:field];
    if (node) {
        [self compileNode:node withNameSpace:nameSpace];
    }

    // 生成当前节点对应的属性定义信息。

    fieldProperty = [[QPNetworkingFieldPropertyModel alloc] init];
    [fieldProperty setValue:alias forKey:QPNetworkingFieldPropertyName];
    [fieldProperty setValue:typeName forKey:QPNetworkingFieldPropertyTypeName];
    [fieldProperty setValue:className forKey:QPNetworkingFieldPropertyClassName];
    [fieldProperty setValue:description forKey:QPNetworkingFieldPropertyComments];

    return fieldProperty;
}

#pragma mark - 接口协议链接。

- (void)link
{
    [self.files removeAllObjects];

    NSString *protocalClassName = NSStringFromClass([self class]);

    // 将所有接口定义数据按编码、别名从小到大排序。

    NSArray *orderedInterfaces = [self.interfaces allValues];
    NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor
                                            sortDescriptorWithKey:QPNetworkingInterfaceName
                                            ascending:YES];
    NSSortDescriptor *aliasSortDescriptor = [NSSortDescriptor
                                             sortDescriptorWithKey:QPNetworkingInterfaceAlias
                                             ascending:YES];
    NSArray *sortDescriptors = @[nameSortDescriptor, aliasSortDescriptor];
    orderedInterfaces = [orderedInterfaces sortedArrayUsingDescriptors:sortDescriptors];

    // 将所有接口定义数据按名字中是否包含协议文档的章节号分成两组。

    NSMutableArray *orderedAllInterfaces = [NSMutableArray array];
    NSMutableArray *orderedNoChaptersInterfaces = [NSMutableArray array];
    for (QPNetworkingInterfaceModel *interface in orderedInterfaces) {
        NSString *description = [interface objectForKey:QPNetworkingInterfaceDescription];
        NSString *chapters = [description
                              stringByReplacingOccurrencesOfString:@"[^0-9.].*$"
                              withString:@""
                              options:NSRegularExpressionSearch
                              range:NSMakeRange(0, [description length])];
        if ([chapters length] > 0) {
            [orderedAllInterfaces addObject:interface];
        }
        else {
            [orderedNoChaptersInterfaces addObject:interface];
        }
    }

    // 对包含协议文档章节号的所有接口定义数据按章节号从小到大排序。

    [orderedAllInterfaces sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *description1 = [obj1 objectForKey:QPNetworkingInterfaceDescription];
        NSString *description2 = [obj2 objectForKey:QPNetworkingInterfaceDescription];
        NSString *chapters1 = [description1
                               stringByReplacingOccurrencesOfString:@"[^0-9.].*$"
                               withString:@""
                               options:NSRegularExpressionSearch
                               range:NSMakeRange(0, [description1 length])];
        NSString *chapters2 = [description2
                               stringByReplacingOccurrencesOfString:@"[^0-9.].*$"
                               withString:@""
                               options:NSRegularExpressionSearch
                               range:NSMakeRange(0, [description2 length])];
        NSArray *nodes1 = [chapters1 componentsSeparatedByString:@"."];
        NSArray *nodes2 = [chapters2 componentsSeparatedByString:@"."];
        NSUInteger count1 = [nodes1 count];
        NSUInteger count2 = [nodes2 count];
        for (NSInteger index = 0; index < MIN(count1, count2); ++index) {
            NSNumber *node1 = @([[nodes1 objectAtIndex:index] integerValue]);
            NSNumber *node2 = @([[nodes2 objectAtIndex:index] integerValue]);
            NSComparisonResult result = [node1 compare:node2];
            if (NSOrderedSame != result) {
                return result;
            }
        }
        return [@(count1) compare:@(count2)];
    }];

    // 将不含协议文档章节号的所有接口定义数据根据编码接近程度由大到小合并已排序
    // 的包含协议文档章节号的所有接口定义数据，组成接口定义数据的最终排序结果。

    for (QPNetworkingInterfaceModel *interface1 in orderedNoChaptersInterfaces) {
        NSString *name1 = [interface1 objectForKey:QPNetworkingInterfaceName];
        const unsigned char *base1 = (const unsigned char *)[name1 UTF8String];

        __block NSUInteger nearestIndex = NSNotFound;
        __block int maxSameness = -1;
        __block int minDifference = 0;

        [orderedAllInterfaces enumerateObjectsUsingBlock:
         ^(id obj, NSUInteger idx, BOOL *stop) {
             NSString *name2 = [obj objectForKey:QPNetworkingInterfaceName];
             const unsigned char *str1 = (const unsigned char *)base1;
             const unsigned char *str2 = (const unsigned char *)[name2 UTF8String];

             while (*str1 && *str1 == *str2) {
                 ++str1;
                 ++str2;
             }

             int sameness = (int)(str1 - base1);
             int difference = (int)*str1 - (int)*str2;

             if (sameness > maxSameness || (sameness == maxSameness &&
                                            abs(difference) < abs(minDifference))) {
                 nearestIndex = idx;
                 maxSameness = sameness;
                 minDifference = difference;
             }
         }];

        if (nearestIndex != NSNotFound) {
            if (minDifference < 0) {
                [orderedAllInterfaces insertObject:interface1 atIndex:nearestIndex];
            }
            else if (nearestIndex + 1 < [orderedAllInterfaces count]) {
                [orderedAllInterfaces insertObject:interface1 atIndex:nearestIndex + 1];
            }
            else {
                [orderedAllInterfaces addObject:interface1];
            }
        }
        else {
            [orderedAllInterfaces addObject:interface1];
        }
    }

    orderedInterfaces = [orderedAllInterfaces copy];

    // 生成接口协议汇总信息列表文档。

    NSString *listFileName = [NSString stringWithFormat:@"%@Summary.html",
                              protocalClassName];
    [self linkOrderedInterfaces:orderedInterfaces
                toListFileNamed:listFileName];

    // 将所有模型类按名称从小到大排列。

    NSArray *orderedClasses = [self.classes allValues];
    orderedClasses = [orderedClasses sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *nodeClassName1 = [obj1 objectForKey:QPNetworkingNodeClassName];
        NSString *nodeClassName2 = [obj2 objectForKey:QPNetworkingNodeClassName];
        return [nodeClassName1 compare:nodeClassName2];
    }];

    // 生成节点模型类头文件。

    NSString *classesHeaderFileName = [NSString stringWithFormat:@"%@Classes.h",
                                       protocalClassName];
    [self linkOrderedClasses:orderedClasses
           toHeaderFileNamed:classesHeaderFileName];

    // 生成节点模型类源文件。

    NSString *classesSourceFileName = [NSString stringWithFormat:@"%@Classes.m",
                                       protocalClassName];
    [self linkOrderedClasses:orderedClasses
           toSourceFileNamed:classesSourceFileName
         withHeaderFileNamed:classesHeaderFileName];

    // 将所有接口按别名从小到大排列。

    NSArray *orderedInvokes = [self.invokes allValues];
    orderedInvokes = [orderedInvokes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *interfaceInvokeName1 = [obj1 objectForKey:QPNetworkingInterfaceInvokeName];
        NSString *interfaceInvokeName2 = [obj2 objectForKey:QPNetworkingInterfaceInvokeName];
        return [interfaceInvokeName1 compare:interfaceInvokeName2];
    }];

    // 生成接口调用函数头文件。

    NSString *invokesHeaderFileName = [NSString stringWithFormat:@"%@Invokes.h",
                                       protocalClassName];
    [self linkOrderedInvokes:orderedInvokes
           toHeaderFileNamed:invokesHeaderFileName
  withClassesHeaderFileNamed:classesHeaderFileName];

    // 生成接口调用函数源文件。

    NSString *invokesSourceFileName = [NSString stringWithFormat:@"%@Invokes.m",
                                       protocalClassName];
    [self linkOrderedInvokes:orderedInvokes
           toSourceFileNamed:invokesSourceFileName
         withHeaderFileNamed:invokesHeaderFileName];
}

- (NSString *)linkNode:(QPNetworkingNodeModel *)node
{
    NSMutableString *content = [[NSMutableString alloc]
                                initWithCapacity:4 * 1024];

    // 生成节点及其下的所有子节点的详细定义信息。

    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *descriptions = [NSMutableArray array];

    [self linkField:node usingBlock:^(NSString *title, NSString *description) {
        if ([titles count] <= 0) {
            title = [title
                     stringByReplacingOccurrencesOfString:@"[(][^)]*[)]$"
                     withString:@""
                     options:NSRegularExpressionSearch
                     range:NSMakeRange(0, [title length])];
        }
        [titles addObject:title];
        [descriptions addObject:description];
    }];

    // 对齐所有节点的描述信息。

    __block NSUInteger maxTitleLength = 32;
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        maxTitleLength = MAX(maxTitleLength, [(NSString *)obj lengthOfBytesUsingEncoding:encoding]);
    }];
    NSString *format = [NSString stringWithFormat:@"| %%-%ds%%@\n", (int)maxTitleLength + 4];

    for (NSInteger index = 0; index < [titles count]; ++index) {
        NSString *title = [titles objectAtIndex:index];
        NSString *description = [descriptions objectAtIndex:index];
        if (0 == index) {
            [content appendFormat:@"| %@\n", title];
        }
        else {
            const char *titleCharacters = [title cStringUsingEncoding:encoding];
            [content appendFormat:format, titleCharacters, description];
        }
    }

    return content;
}

- (void)linkField:(QPNetworkingFieldModel *)field
       usingBlock:(void (^)(NSString *title, NSString *description))block
{
    // 取出字段的相关定义数据。

    QPNetworkingNodeModel *node = [self nodeForField:field];
    NSString *name = [field objectForKey:QPNetworkingFieldName];
    NSString *alias = [field objectForKey:QPNetworkingFieldAlias];
    NSString *constraint = [field objectForKey:QPNetworkingFieldConstraint];
    NSArray *subfields = [node objectForKey:QPNetworkingNodeSubfields];
    NSString *description = [field objectForKey:QPNetworkingFieldDescription];
    constraint = QPNvlString(constraint, @"1");

    // 生成字段的详细定义信息。

    NSString *title = [NSString stringWithFormat:@"- %@", name];
    if (![alias isEqualToString:name]) {
        title = [title stringByAppendingFormat:@" (%@)", alias];
    }
    if (![constraint isEqualToString:@"1"]) {
        title = [title stringByAppendingFormat:@" %@", constraint];
    }
    block(title, description);

    // 遍历字段的所有子节点并生成详细定义信息。

    for (QPNetworkingFieldModel *subfield in subfields) {
        [self linkField:subfield usingBlock:
         ^(NSString *title, NSString *description) {
             title = [NSString stringWithFormat:@"  %@", title];
             block(title, description);
         }];
    }
}

- (void)linkOrderedInterfaces:(NSArray *)orderedInterfaces
              toListFileNamed:(NSString *)listFileName
{
    NSMutableString *content = [[NSMutableString alloc]
                                initWithCapacity:1024 * 1024];

    NSMutableString *detail = [[NSMutableString alloc]
                               initWithCapacity:1024 * 1024];

    // 添加网页标题、样式等数据。

    [content appendString:@"<html>\n"];
    [content appendString:@"<head>\n"];
    [content appendFormat:@"<title>%@接口协议汇总信息</title>\n", [self name]];
    [content appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n"];
    [content appendString:@"<style type=\"text/css\">\nbody {\n  font-family: \"Courier New\", \"Arial\", \"Helvetica\", \"sans-serif\";\n  font-size: 14px;\n  color: #333333;\n}\n\ntable {\n  border-collapse: collapse;\n  border-spacing: 0;\n  width: 100%;\n  overflow: auto;\n  word-break: keep-all;\n  font-size: 14px;\n}\n\ntr {\n  background-color: #fff;\n  border-top: 1px solid #ccc;\n}\n\ntr:nth-child(2n) {\n  background-color: #f8f8f8;\n}\n\nth {\n  font-weight: bold;\n}\n\ntd, th {\n  padding: 8px 4px;\n  border: 1px solid #ddd;\n  vertical-align: top;\n}\n\npre>code {\n  padding: 0;\n  margin: 0;\n  font-size: 100%;\n  word-break: normal;\n  white-space: pre;\n  background: transparent;\n  border: 0;\n}\n\na {\n  color: #333333;\n  text-decoration: none;\n}\n\na:hover {\n  color: #05f;\n  text-decoration: underline;\n}\n</style>\n"];
    [content appendString:@"</head>\n"];
    [content appendString:@"<body>\n"];
    [content appendFormat:@"<br/><p><center><h1>%@接口协议汇总信息</h1></center></p>\n", [self name]];
    [content appendString:@"<br/><p><h2>一、接口索引列表</h2></p>\n"];
    [detail  appendString:@"<br/><p><h2>二、接口详细定义信息</h2></p>\n"];

    // 添加接口协议汇总信息列表的表头行。

    [content appendString:@"<table>\n"];
    [content appendString:@"<thead>\n"];
    [content appendString:@"<tr style=\"background-color: #e8e8e8;\">\n"];
    [content appendString:@"<th>序号</th>\n"];
    [content appendString:@"<th>接口编码</th>\n"];
    [content appendString:@"<th>接口别名</th>\n"];
    [content appendString:@"<th>接口名称</th>\n"];
    [content appendString:@"<th>创建/修改人</th>\n"];
    [content appendString:@"<th>创建/修改时间</th>\n"];
    [content appendString:@"</tr>\n"];
    [content appendString:@"</thead>\n"];

    // 对所有接口定义数据的行号进行排序。

    NSArray *orderedLineNumbers = [orderedInterfaces valueForKey:
                                   QPNetworkingInterfaceLineNumber];
    orderedLineNumbers = [orderedLineNumbers sortedArrayUsingComparator:
                          ^NSComparisonResult(id obj1, id obj2) {
                              return [obj1 compare:obj2];
                          }];

    // 遍历所有接口定义数据，添加接口协议汇总列表的内容行。

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [content appendString:@"<tbody>\n"];

    for (NSUInteger index = 0; index < [orderedInterfaces count]; ++index) {
        QPNetworkingInterfaceModel *interface = [orderedInterfaces objectAtIndex:index];
        NSString *name = [interface objectForKey:QPNetworkingInterfaceName];
        NSString *alias = [interface objectForKey:QPNetworkingInterfaceAlias];
        QPNetworkingNodeModel *request = [interface objectForKey:QPNetworkingInterfaceRequest];
        QPNetworkingNodeModel *response = [interface objectForKey:QPNetworkingInterfaceResponse];
        NSString *requestContentKeyPath = [interface objectForKey:QPNetworkingInterfaceRequestContentKeyPath];
        NSString *responseContentKeyPath = [interface objectForKey:QPNetworkingInterfaceResponseContentKeyPath];
        NSString *description = [interface objectForKey:QPNetworkingInterfaceDescription];
        NSString *filePath = [interface objectForKey:QPNetworkingInterfaceFilePath];
        NSNumber *lineNumber = [interface objectForKey:QPNetworkingInterfaceLineNumber];

        // 将请求/应答报文的根节点设置为内容节点。

        if ([requestContentKeyPath length] > 0) {
            request = [self nodeForKeyPath:requestContentKeyPath atNode:request];
        }

        if ([responseContentKeyPath length] > 0) {
            response = [self nodeForKeyPath:responseContentKeyPath atNode:response];
        }

        // 生成请求/应答报文的详细定义信息。

        NSString *requestDescription = [self linkNode:request];
        NSString *responseDescription = [self linkNode:response];

        // 计算接口定义语句的起始行号及范围。

        NSUInteger lineStart = [lineNumber unsignedIntegerValue];
        NSUInteger lineRange = 1;
        NSUInteger lineIndex = [orderedLineNumbers indexOfObject:lineNumber];

        NSUInteger startLineNumber;
        NSUInteger endLineNumber = lineStart;
        NSString *position = nil;

        if (lineIndex != NSNotFound && lineIndex > 0) {
            startLineNumber = [[orderedLineNumbers
                                objectAtIndex:lineIndex - 1]
                               unsignedIntegerValue] + 1;
            endLineNumber = [lineNumber unsignedIntegerValue];
            lineRange = MAX((endLineNumber - startLineNumber + 1) / 2, 1);
            lineStart = MAX(startLineNumber, endLineNumber - lineRange + 1);
            lineRange = MIN(lineRange, endLineNumber - startLineNumber + 1);
            position = [NSString stringWithFormat:
                        @"%@ (%d ~ %d)",
                        [filePath lastPathComponent],
                        (int)startLineNumber,
                        (int)endLineNumber];
        }
        else {
            position = [NSString stringWithFormat:
                        @"%@ (? ~ %d)",
                        [filePath lastPathComponent],
                        (int)endLineNumber];
        }

        // 获取该接口在git仓库上的可以检测得到的最开始的提交信息。

        NSString *gitinfoPath = [NSString stringWithFormat:
                                 @"%@.%@.%@.gitinfo.tmp",
                                 filePath, name, alias];

        NSString *commandLine = [NSString stringWithFormat:
                                 @"(git blame -l -L %d,+%d '%@' 2>/dev/null | "
                                 @"sed 's/^[[:space:]]*[[:punct:]]*\\([0-9a-fA-F]\\{1,\\}\\)[^(]*[(]\\([^)]*\\)[[:space:]]\\([[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}[[:space:]]*[[:digit:]]\\{2\\}:[[:digit:]]\\{2\\}:[[:digit:]]\\{2\\}\\)[^)]*[)].*$/\\3,\\1,\\2/' | "
                                 @"sed 's/[[:space:]]*$//' | "
                                 @"sort | "
                                 @"head -1 && "
                                 @"git config --get remote.origin.url) |"
                                 @"awk 'BEGIN {is_first_line = 1;} { if (is_first_line) { printf \"%%s\", $0; is_first_line = 0; } else { printf \",%%s\", $0; } }' "
                                 @"> '%@'",
                                 (int)lineStart,
                                 (int)lineRange,
                                 filePath,
                                 gitinfoPath];
        commandLine = commandLine;

#if !(TARGET_OS_IPHONE || TARGET_OS_SIMULATOR)

        system([commandLine UTF8String]);

#endif /* !(TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) */

        NSString *gitinfo = [NSString stringWithContentsOfFile:gitinfoPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
        [fileManager removeItemAtPath:gitinfoPath error:nil];

        // 根据获得的git仓库提交信息，分析出创建人、创建时间以及提交sha编码。

        NSString *author = nil;
        NSString *createdate = nil;
        NSString *gitcommit = nil;
        NSString *gitremote = nil;

        NSArray *gitinfos = [gitinfo componentsSeparatedByString:@","];
        if ([gitinfos count] >= 4) {
            createdate = [gitinfos objectAtIndex:0];
            gitcommit = [gitinfos objectAtIndex:1];
            author = [gitinfos objectAtIndex:2];
            gitremote = [[gitinfos subarrayWithRange:
                          NSMakeRange(3, [gitinfos count] - 3)]
                         componentsJoinedByString:@","];
        }

        // 对所有输出信息进行html特殊字符转义。

        NSString *(^HTMLEncodedText)(NSString *text) = ^NSString *(NSString *text){
            text = [text stringByReplacingOccurrencesOfString:@"&"
                                                   withString:@"&amp;"];
            text = [text stringByReplacingOccurrencesOfString:@"\""
                                                   withString:@"&quot;"];
            text = [text stringByReplacingOccurrencesOfString:@"<"
                                                   withString:@"&lt;"];
            text = [text stringByReplacingOccurrencesOfString:@">"
                                                   withString:@"&gt;"];
            return text;
        };

        name = HTMLEncodedText(name);
        alias = HTMLEncodedText(alias);
        description = HTMLEncodedText(description);
        position = HTMLEncodedText(position);
        author = HTMLEncodedText(author);
        createdate = HTMLEncodedText(createdate);
        gitcommit = HTMLEncodedText(gitcommit);
        gitremote = HTMLEncodedText(gitremote);
        requestDescription = HTMLEncodedText(requestDescription);
        responseDescription = HTMLEncodedText(responseDescription);

        // 生成接口协议汇总信息列表的内容行。

        [content appendString:@"<tr>\n"];
        [content appendFormat:@"<td style=\"text-align:right\">%d</td>\n", (int)index + 1];
        [content appendFormat:@"<td><pre><code><a href=\"#%@.%@\">%@</a></code></pre></td>\n", name, alias, name];
        [content appendFormat:@"<td><pre><code><a href=\"#%@.%@\">%@</a></code></pre></td>\n", name, alias, alias];
        [content appendFormat:@"<td><pre><code><a href=\"#%@.%@\">%@</a></code></pre></td>\n", name, alias, description];
        [content appendFormat:@"<td><center><pre><code>%@</code></pre></center></td>\n", QPNvlString(author, @"-")];
        [content appendFormat:@"<td><center><pre><code>%@</code></pre></center></td>\n", QPNvlString(createdate, @"-")];
        [content appendString:@"</tr>\n"];

        // 生成接口协议汇总信息列表的详细定义信息。

        [detail appendString:@"<p>\n"];
        [detail appendFormat:@"<h3><a name=\"%@.%@\">%d - %@</a></h3>\n", name, alias, (int)index + 1, description];
        [detail appendString:@"<table>\n"];
        [detail appendFormat:@"<tr style=\"background-color: #e8e8e8;\"><th><strong>%@</strong></th></tr>\n", description];
        [detail appendString:@"<tr><td><strong>接口编码:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", name];
        [detail appendString:@"<tr><td><strong>接口别名:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", alias];
        [detail appendString:@"<tr><td><strong>定义文件:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><a href=\"%@\"><pre><code>%@</code></pre></a></td></tr>\n", [[NSURL fileURLWithPath:filePath] absoluteString], position];
        [detail appendString:@"<tr><td><strong>代码仓库(git-remote-url):</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><a href=\"%@\"><pre><code>%@</code></pre></a></td></tr>\n", QPNonnullString(gitremote), QPNvlString(gitremote, @"-")];
        [detail appendString:@"<tr><td><strong>提交节点(git-commit-sha):</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", QPNvlString(gitcommit, @"-")];
        [detail appendString:@"<tr><td><strong>创建/修改人:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", QPNvlString(author, @"-")];
        [detail appendString:@"<tr><td><strong>创建/修改时间:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", QPNvlString(createdate, @"-")];
        [detail appendString:@"<tr><td><strong>请求报文:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", requestDescription];
        [detail appendString:@"<tr><td><strong>应答报文:</strong></td></tr>\n"];
        [detail appendFormat:@"<tr><td><pre><code>%@</code></pre></td></tr>\n", responseDescription];
        [detail appendString:@"</table>\n"];
        [detail appendString:@"</p><br/><br/>\n"];
    }

    // 将所有接口协议汇总信息合并起来。

    [content appendString:@"</tbody>\n"];
    [content appendString:@"</table>\n"];
    [content appendString:@"<br/>\n"];
    [content appendString:detail];
    [content appendString:@"<br/>\n"];
    [content appendString:@"</body>\n"];
    [content appendString:@"</html>\n"];

    // 生成webarchive网页打包文档。

#if 0

    NSData *htmlData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *webarchive;
    webarchive = @{@"WebMainResource":@{@"WebResourceMIMEType":@"text/html",
                                        @"WebResourceTextEncodingName":@"UTF-8",
                                        @"WebResourceFrameName":@"",
                                        @"WebResourceURL":@"",
                                        @"WebResourceData":htmlData}};
    NSData *webarchiveData = [NSPropertyListSerialization
                              dataWithPropertyList:webarchive
                              format:NSPropertyListBinaryFormat_v1_0
                              options:0
                              error:nil];
    content = webarchiveData;

#endif

    [self.files setValue:content forKey:listFileName];
}

- (void)linkOrderedClasses:(NSArray *)orderedClasses
         toHeaderFileNamed:(NSString *)headerFileName
{
    NSMutableString *content = [[NSMutableString alloc]
                                initWithCapacity:1024 * 1024];

    // 添加文件头注释。

    [content appendString:@"//\n"];
    [content appendFormat:@"//  %@\n", headerFileName];
    [content appendString:@"//\n"];
    [content appendFormat:@"//  This file is automatically generate by QPFoundation for %@.\n", [self class]];
    [content appendString:@"//  Don't add or modify any code here, that will be discard by generate action.\n"];
    [content appendString:@"//\n\n\n"];

    // 添加头文件导入声明。

    [content appendString:@"#import <Foundation/Foundation.h>\n\n\n"];

    // 添加@class前置声明。

    for (QPNetworkingNodeClassModel *nodeClass in orderedClasses) {
        [content appendFormat:@"@class %@;\n",
         [nodeClass objectForKey:QPNetworkingNodeClassName]];
    }

    // 遍历所有模型类添加其声明。

    NSString *stringClassName = NSStringFromClass([NSString class]);

    for (QPNetworkingNodeClassModel *nodeClass in orderedClasses) {
        NSString *name = [nodeClass objectForKey:QPNetworkingNodeClassName];
        NSArray *properties = [nodeClass objectForKey:QPNetworkingNodeClassProperties];
        NSString *comments = [nodeClass objectForKey:QPNetworkingNodeClassComments];

        [content appendString:@"\n\n"];

        // 添加模型类注释。

        if ([comments length] > 0) {
            [content appendFormat:@"/**\n *  %@\n */\n", comments];
        }

        // 添加@interface标记。

        [content appendFormat:@"@interface %@ : NSObject\n\n", name];

        // 遍历模型类的所有属性添加其声明。

        for (QPNetworkingFieldPropertyModel *fieldProperty in properties) {
            NSString *name = [fieldProperty objectForKey:QPNetworkingFieldPropertyName];
            NSString *typeName = [fieldProperty objectForKey:QPNetworkingFieldPropertyTypeName];
            NSString *comments = [fieldProperty objectForKey:QPNetworkingFieldPropertyComments];

            NSString *policy = @"copy";
            if (![typeName isEqualToString:stringClassName]) {
                policy = @"strong";
            }

            NSString *statement = [NSString stringWithFormat:
                                   @"@property (nonatomic, %@) %@ *%@;",
                                   policy, typeName, name];

            // 添加属性的注释。

            if ([comments length] > 0) {
                statement = [NSString stringWithFormat:
                             @"%-63s // %@\n",
                             [statement UTF8String],
                             comments];
            }
            else {
                statement = [statement stringByAppendingString:@"\n"];
            }

            // 添加属性的声明。

            [content appendString:statement];
        }

        // 遍历模型类的所有属性添加编程时类型确认支持。

        BOOL needEmptyLine = YES;

        for (QPNetworkingFieldPropertyModel *fieldProperty in properties) {
            NSString *name = [fieldProperty objectForKey:QPNetworkingFieldPropertyName];
            NSString *className = [fieldProperty objectForKey:QPNetworkingFieldPropertyClassName];

            if ([className length] <= 0) {
                continue;
            }

            if (needEmptyLine) {
                [content appendString:@"\n"];
                needEmptyLine = NO;
            }

            [content appendFormat:@"@property (nonatomic, assign, readonly) %@ *%@__T__;\n",
             className, name];

            [content appendFormat:@"@property (nonatomic, assign, readonly) Class %@__C__;\n",
             name];
        }

        // 添加@end标记。

        [content appendFormat:@"\n@end\n"];
    }

    [self.files setValue:content forKey:headerFileName];
}

- (void)linkOrderedClasses:(NSArray *)orderedClasses
         toSourceFileNamed:(NSString *)sourceFileName
       withHeaderFileNamed:(NSString *)headerFileName
{
    NSMutableString *content = [[NSMutableString alloc]
                                initWithCapacity:1024 * 1024];

    // 添加文件头注释。

    [content appendString:@"//\n"];
    [content appendFormat:@"//  %@\n", sourceFileName];
    [content appendString:@"//\n"];
    [content appendFormat:@"//  This file is automatically generate by QPFoundation for %@.\n", [self class]];
    [content appendString:@"//  Don't add or modify any code here, that will be discard by generate action.\n"];
    [content appendString:@"//\n\n\n"];

    // 添加头文件导入声明。

    [content appendFormat:@"#import \"%@\"\n", headerFileName];

    // 遍历所有模型类添加其实现。

    NSString *stringClassName = NSStringFromClass([NSString class]);

    for (QPNetworkingNodeClassModel *nodeClass in orderedClasses) {
        NSString *name = [nodeClass objectForKey:QPNetworkingNodeClassName];
        NSMutableArray *properties = [nodeClass objectForKey:QPNetworkingNodeClassProperties];

        [content appendString:@"\n\n"];

        // 添加@implementation标记。

        [content appendFormat:@"@implementation %@\n\n", name];

        // 遍历模型类的所有属性，生成其初始化对象。

        NSMutableString *initialize = [[NSMutableString alloc] init];

        for (QPNetworkingFieldPropertyModel *fieldProperty in properties) {
            NSString *name = [fieldProperty objectForKey:QPNetworkingFieldPropertyName];
            NSString *typeName = [fieldProperty objectForKey:QPNetworkingFieldPropertyTypeName];

            if (![typeName isEqualToString:stringClassName]) {
                [initialize appendFormat:@"        self.%@ = [[%@ alloc] init];\n",
                 name, typeName];
            }
        }

        // 遍历模型类的所有属性，为有子节点的属性记录其节点模型类类对象。

        for (QPNetworkingFieldPropertyModel *fieldProperty in properties) {
            NSString *name = [fieldProperty objectForKey:QPNetworkingFieldPropertyName];
            NSString *className = [fieldProperty objectForKey:QPNetworkingFieldPropertyClassName];

            if ([className length] <= 0) {
                continue;
            }

            [initialize appendFormat:@"        _%@__C__ = [%@ class];\n",
             name, className];
        }

        if ([initialize length] > 0) {
            [content appendFormat:
             @"- (instancetype)init\n{\n"
             @"    self = [super init];\n"
             @"    if (self) {\n%@    }\n"
             @"    return self;\n}\n\n", initialize];
        }

        // 添加@end标记。

        [content appendString:@"@end\n"];
    }

    [self.files setValue:content forKey:sourceFileName];
}

- (void)linkOrderedInvokes:(NSArray *)orderedInvokes
         toHeaderFileNamed:(NSString *)headerFileName
withClassesHeaderFileNamed:(NSString *)classesHeaderFileName
{
    NSMutableString *content = [[NSMutableString alloc]
                                initWithCapacity:1024 * 1024];

    // 添加文件头注释。

    [content appendString:@"//\n"];
    [content appendFormat:@"//  %@\n", headerFileName];
    [content appendString:@"//\n"];
    [content appendFormat:@"//  This file is automatically generate by QPFoundation for %@.\n", [self class]];
    [content appendString:@"//  Don't add or modify any code here, that will be discard by generate action.\n"];
    [content appendString:@"//\n\n\n"];

    // 添加头文件导入声明。

    [content appendString:@"#import <Foundation/Foundation.h>\n"];
    [content appendFormat:@"#import \"%@\"\n", classesHeaderFileName];

    // 遍历所有接口调用函数添加其函数声明。

    NSString *operationClassName = [self operationName];
    for (QPNetworkingInterfaceInvokeModel *interfaceInvoke in orderedInvokes) {
        NSString *name = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeName];
        NSString *enhancedName = [interfaceInvoke objectForKey:QPNetworkingInterfaceEnhancedInvokeName];
        NSString *requestClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeRequestClassName];
        NSString *responseClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeResponseClassName];
        NSString *requestContentClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeRequestContentClassName];
        NSString *responseContentClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeResponseContentClassName];
        NSString *comments = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeComments];

        if ([requestContentClassName length] <= 0) {
            requestContentClassName = requestClassName;
        }

        if ([responseContentClassName length] <= 0) {
            responseContentClassName = responseClassName;
        }

        [content appendString:@"\n\n"];

        // 添加接口调用函数注释。

        if ([comments length] > 0) {
            [content appendFormat:@"/**\n *  %@\n */\n", comments];
        }

        // 添加简化版的接口调用函数。

        [content appendFormat:@"FOUNDATION_EXPORT\n%@ *\n%@(\n",
         operationClassName, name];

        [content appendFormat:@"    void (^initial)(%@ *request),\n",
         requestContentClassName];

        [content appendFormat:@"    void (^success)(%@ *response),\n",
         responseContentClassName];

        [content appendFormat:@"    void (^failure)(%@ *error));\n\n",
         [NSError class]];

        // 添加增加版的接口调用函数。

        [content appendFormat:@"FOUNDATION_EXPORT\n%@ *\n%@(\n",
         operationClassName, enhancedName];

        [content appendFormat:
         @"    void (^initial)(%@ *req,\n"
         @"                    %@ *operation),\n",
         requestClassName, operationClassName];

        [content appendFormat:
         @"    void (^success)(%@ *req,\n"
         @"                    %@ *rsp,\n"
         @"                    %@ *operation),\n",
         requestClassName, responseClassName, operationClassName];

        [content appendFormat:
         @"    void (^failure)(%@ *error,\n"
         @"                    %@ *req,\n"
         @"                    %@ *rsp,\n"
         @"                    %@ *operation));\n",
         [NSError class], requestClassName, responseClassName, operationClassName];
    }

    [self.files setValue:content forKey:headerFileName];
}

- (void)linkOrderedInvokes:(NSArray *)orderedInvokes
            toSourceFileNamed:(NSString *)sourceFileName
          withHeaderFileNamed:(NSString *)headerFileName
{
    NSMutableString *content = [[NSMutableString alloc]
                                initWithCapacity:1024 * 1024];

    // 添加文件头注释。

    [content appendString:@"//\n"];
    [content appendFormat:@"//  %@\n", sourceFileName];
    [content appendString:@"//\n"];
    [content appendFormat:@"//  This file is automatically generate by QPFoundation for %@.\n", [self class]];
    [content appendString:@"//  Don't add or modify any code here, that will be discard by generate action.\n"];
    [content appendString:@"//\n\n\n"];

    // 添加头文件导入声明。

    [content appendFormat:@"#import \"%@\"\n", headerFileName];

    // 遍历所有接口调用函数添加其函数实现。

    NSString *operationClassName = [self operationName];
    for (QPNetworkingInterfaceInvokeModel *interfaceInvoke in orderedInvokes) {
        NSString *name = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeName];
        NSString *enhancedName = [interfaceInvoke objectForKey:QPNetworkingInterfaceEnhancedInvokeName];
        NSString *alias = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeAlias];
        NSString *requestClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeRequestClassName];
        NSString *responseClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeResponseClassName];
        NSString *requestContentKeyPath = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeRequestContentKeyPath];
        NSString *responseContentKeyPath = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeResponseContentKeyPath];
        NSString *requestContentClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeRequestContentClassName];
        NSString *responseContentClassName = [interfaceInvoke objectForKey:QPNetworkingInterfaceInvokeResponseContentClassName];

        if ([requestContentClassName length] <= 0) {
            requestContentClassName = requestClassName;
        }

        if ([responseContentClassName length] <= 0) {
            responseContentClassName = responseClassName;
        }

        [content appendString:@"\n\n"];

        // 添加简化版的接口调用函数。

        [content appendFormat:@"%@ *\n%@(\n",
         operationClassName, name];

        [content appendFormat:@"    void (^initial)(%@ *request),\n",
         requestContentClassName];

        [content appendFormat:@"    void (^success)(%@ *response),\n",
         responseContentClassName];

        [content appendFormat:@"    void (^failure)(%@ *error))\n",
         [NSError class]];

        [content appendFormat:
         @"{\n    return (%@ *)QPNetworkingCommitOperation(@\"%@\", @\"%@\", ",
         operationClassName, self.name, alias];

        [content appendFormat:
         @"^(QPNetworkingOperation *operation) {\n"
         @"        if (initial) initial([operation.requestObject valueForKeyPath:@\"%@\"]);\n"
         @"    }, ",
         requestContentKeyPath];

        [content appendFormat:
         @"^(QPNetworkingOperation *operation) {\n"
         @"        if (success) success([operation.responseObject valueForKeyPath:@\"%@\"]);\n"
         @"    }, ",
         responseContentKeyPath];

        [content appendString:
         @"^(QPNetworkingOperation *operation) {\n"
         @"        if (failure) failure(operation.error);\n"
         @"    });\n}\n\n\n"];

        // 添加增加版的接口调用函数。

        [content appendFormat:@"%@ *\n%@(\n",
         operationClassName, enhancedName];

        [content appendFormat:
         @"    void (^initial)(%@ *req,\n"
         @"                    %@ *operation),\n",
         requestClassName, operationClassName];

        [content appendFormat:
         @"    void (^success)(%@ *req,\n"
         @"                    %@ *rsp,\n"
         @"                    %@ *operation),\n",
         requestClassName, responseClassName, operationClassName];

        [content appendFormat:
         @"    void (^failure)(%@ *error,\n"
         @"                    %@ *req,\n"
         @"                    %@ *rsp,\n"
         @"                    %@ *operation))\n",
         [NSError class], requestClassName, responseClassName, operationClassName];

        [content appendFormat:
         @"{\n    return (%@ *)QPNetworkingCommitOperation(@\"%@\", @\"%@\", ",
         operationClassName, self.name, alias];

        [content appendFormat:
         @"^(QPNetworkingOperation *operation) {\n"
         @"        if (initial) initial(operation.requestObject, (%@ *)operation);\n"
         @"    }, ",
         operationClassName];

        [content appendFormat:
         @"^(QPNetworkingOperation *operation) {\n"
         @"        if (success) success(operation.requestObject, operation.responseObject, (%@ *)operation);\n"
         @"    }, ",
         operationClassName];

        [content appendFormat:
         @"^(QPNetworkingOperation *operation) {\n"
         @"        if (failure) failure(operation.error, operation.requestObject, operation.responseObject, (%@ *)operation);\n"
         @"    });\n}\n",
         operationClassName];
    }

    [self.files setValue:content forKey:sourceFileName];
}

#pragma mark - 接口协议生成。

- (void)make
{
    // Nothing to do.
}

- (void)makeToDirectory:(NSString *)directory
{
    // 编译链接。

    [self compile];
    [self link];

    // 将所有结果文件生成到指定目录中。

    directory = [directory stringByExpandingTildeInPath];

    for (NSString *name in self.files) {
        id content = [self.files objectForKey:name];
        NSString *path = [directory stringByAppendingPathComponent:name];

        if ([content isKindOfClass:[NSString class]]) {
            [(NSString *)content writeToFile:path
                                  atomically:YES
                                    encoding:NSUTF8StringEncoding
                                       error:nil];
        }
        else if ([content isKindOfClass:[NSData class]]) {

            // 如果是接口协议信息汇总列表文档(.webarchive)，则设置完整的文件URL。

            if ([NSPropertyListSerialization
                 propertyList:content
                 isValidForFormat:NSPropertyListBinaryFormat_v1_0]) {

                NSDictionary *webarchive = [NSPropertyListSerialization
                                            propertyListWithData:content
                                            options:NSPropertyListMutableContainers
                                            format:nil
                                            error:nil];

                NSString *URLString = [[NSURL fileURLWithPath:path] absoluteString];
                NSString *URLKeyPath = @"WebMainResource.WebResourceURL";

                if ([[webarchive valueForKeyPath:URLKeyPath] isEqualToString:@""]) {
                    [webarchive setValue:URLString forKeyPath:URLKeyPath];
                    NSData *webarchiveData = [NSPropertyListSerialization
                                              dataWithPropertyList:webarchive
                                              format:NSPropertyListBinaryFormat_v1_0
                                              options:0
                                              error:nil];
                    content = QPNvl(webarchiveData, content);
                }
            }

            [(NSData *)content writeToFile:path atomically:YES];
        }
    }
}

#pragma mark - 接口测试桩生成。

- (void)stub
{
    // Nothing to do.
}

- (void)stubToDirectory:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    directory = [directory stringByExpandingTildeInPath];

    NSArray *allInterfaces = [self.interfaces allValues];
    for (QPNetworkingInterfaceModel *interface in allInterfaces) {

        // 获取接口对应的测试桩文件的路径。

        NSString *stubName = [self stubNameForInterface:interface];
        NSString *stubPath = [directory stringByAppendingPathComponent:stubName];
        if ([stubPath length] <= 0 ||
            [fileManager fileExistsAtPath:stubPath]) {
            continue;
        }

        // 获取接口对应的测试桩文件的内容。

        NSData *stubData = [self stubDataForInterface:interface];
        if (!stubData) {
            continue;
        }

        [stubData writeToFile:stubPath atomically:YES];

    }
}

- (NSString *)stubNameForInterface:(QPNetworkingInterfaceModel *)interface
{
    return [[interface objectForKey:QPNetworkingInterfaceName]
            stringByAppendingPathExtension:@"json"];
}

- (NSData *)stubDataForInterface:(QPNetworkingInterfaceModel *)interface
{
    // 获取接口返回报文对应的测试桩对象。

    id stubObject = [self stubObjectForInterface:interface];
    if (!stubObject) {
        return nil;
    }

    // 将测试桩对象转换为JSON格式报文。

    return [NSJSONSerialization dataWithJSONObject:stubObject
                                           options:NSJSONWritingPrettyPrinted
                                             error:NULL];
}

- (id)stubObjectForInterface:(QPNetworkingInterfaceModel *)interface
{
    return [self stubObjectForNode:[self nodeForResponseOfInterface:interface]];
}

- (id)stubObjectForNode:(QPNetworkingNodeModel *)node
{
    if (!node) {
        return nil;
    }

    // 节点字段使用字典组表示。

    NSMutableDictionary *stub = [[NSMutableDictionary alloc] init];

    // 遍历当前节点其下的子字段，分别生成其测试桩对象。

    NSArray *subfields = [node objectForKey:QPNetworkingNodeSubfields];
    for (QPNetworkingFieldModel *field in subfields) {
        NSString *name = [field objectForKey:QPNetworkingFieldName];
        [stub setValue:[self stubObjectForField:field] forKey:name];
    }

    return stub;
}

- (id)stubObjectForField:(QPNetworkingFieldModel *)field
{
    if (!field) {
        return nil;
    }

    id stub = nil;

    // 获取当前字段相关属性。

    QPNetworkingNodeModel *node = [self nodeForField:field];
    NSString *name = [field objectForKey:QPNetworkingFieldName];
    NSString *constraint = [field objectForKey:QPNetworkingFieldConstraint];
    NSString *description = [field objectForKey:QPNetworkingFieldDescription];

    // 如果当前是一个节点字段，则使用字典组表示，否则使用字符串表示。

    if (node) {
        stub = [self stubObjectForNode:node];
    }
    else {
        stub = QPNvlString(description, name);
    }

    // 如果当前字段的约束允许为多个，则使用数组表示。

    if ([constraint isEqualToString:@"+"]
        || [constraint isEqualToString:@"＋"]
        || [constraint isEqualToString:@"*"]
        || [constraint isEqualToString:@"＊"]) {
        stub = [NSMutableArray arrayWithObjects:stub, nil];
    }

    return stub;
}

#pragma mark - 接口协议回调。

- (id)callbackForRequest:(id)requestObject
             atInterface:(QPNetworkingInterfaceModel *)interface
              withSender:(id)sender
{
    QPNetworkingNodeModel *request = [self nodeForRequestOfInterface:interface];
    return [self callbackForObject:requestObject atNode:request withSender:sender];
}

- (id)callbackForResponse:(id)responseObject
              atInterface:(QPNetworkingInterfaceModel *)interface
               withSender:(id)sender
{
    QPNetworkingNodeModel *response = [self nodeForResponseOfInterface:interface];
    return [self callbackForObject:responseObject atNode:response withSender:sender];
}

- (id)callbackForObject:(id)nodeObject
                 atNode:(QPNetworkingNodeModel *)node
             withSender:(id)sender
{
    // 提取节点定义信息。

    NSMutableArray *nodeSubfields = [node objectForKey:QPNetworkingNodeSubfields];
    NSString *nodeCallback = [node objectForKey:QPNetworkingNodeCallback];

    // 先遍历所有子节点进行回调处理。

    NSString *mutableArrayTypeName = NSStringFromClass([NSMutableArray class]);

    for (QPNetworkingFieldModel *field in nodeSubfields) {

        // 提取字段定义信息。

        NSString *fieldAlias = [field objectForKey:QPNetworkingFieldAlias];
        NSString *fieldCallback = [field objectForKey:QPNetworkingFieldCallback];
        NSString *fieldType = [self typeNameForField:field withNameSpace:nil];
        QPNetworkingNodeModel *fieldNode = [self nodeForField:field];

        // 获取当前字段的值。

        id oldvalue = [nodeObject valueForKey:fieldAlias];
        id newvalue = oldvalue;

        // 如果当前字段的值是一个可变数组，则需要遍历数组中每一个元素进行回调。

        if ([fieldType isEqualToString:mutableArrayTypeName]) {
            NSMutableArray *values = oldvalue;
            for (NSUInteger index = 0; index < [values count]; ++index) {
                oldvalue = [values objectAtIndex:index];
                newvalue = oldvalue;

                // 如果当前字段是节点节段，则先对子节点进行回调。

                if (fieldNode) {
                    newvalue = [self callbackForObject:newvalue
                                                atNode:fieldNode
                                            withSender:sender];
                }

                // 如果当前字段有设置回调，则调用回调方法，并获取返回结果。

                if (fieldCallback) {
                    newvalue = [self callbackForObject:newvalue
                                         usingCallback:fieldCallback
                                            withSender:sender];
                }

                // 使用回调结果替换当前对象。

                if (!newvalue) {
                    [values removeObjectAtIndex:index];
                    --index;
                }
                else if (newvalue != oldvalue) {
                    [values replaceObjectAtIndex:index withObject:newvalue];
                }
            }
        }
        else {

            // 如果当前字段是节点节段，则先对子节点进行回调。

            if (fieldNode) {
                newvalue = [self callbackForObject:newvalue
                                            atNode:fieldNode
                                        withSender:sender];
            }

            // 如果当前字段有设置回调，则调用回调方法，并获取返回结果。

            if (fieldCallback) {
                newvalue = [self callbackForObject:newvalue
                                     usingCallback:fieldCallback
                                        withSender:sender];
            }

            // 使用回调结果替换当前对象。

            [nodeObject setValue:newvalue forKey:fieldAlias];
        }
    }

    // 如果当前节点有设置回调，则调用回调方法，并获取返回结果。

    if (nodeCallback) {
        nodeObject = [self callbackForObject:nodeObject
                               usingCallback:nodeCallback
                                  withSender:sender];
    }

    return nodeObject;
}

- (id)callbackForObject:(id)anObject
          usingCallback:(NSString *)callback
             withSender:(id)sender
{
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
    SEL selector = NSSelectorFromString(callback);
    if (selector && [self respondsToSelector:selector]) {
        anObject = [self performSelector:selector
                              withObject:anObject
                              withObject:sender];
    }
    _Pragma("clang diagnostic pop")
    return anObject;
}

#pragma mark - 接口协议转换。

- (NSDictionary *)dictionaryForRequest:(id)requestObject
                           atInterface:(QPNetworkingInterfaceModel *)interface
{
    QPNetworkingNodeModel *request = [self nodeForRequestOfInterface:interface];
    return [self dictionaryForObject:requestObject atNode:request];
}

- (id)responseForDictionary:(NSDictionary *)dictionary
                atInterface:(QPNetworkingInterfaceModel *)interface
       compatibleConstraint:(BOOL)compatibleConstraint
{
    NSString *nameSpace = [self nameSpaceForInterface:interface];
    QPNetworkingNodeModel *response = [self nodeForResponseOfInterface:interface];
    return [self objectForDictionary:dictionary
                              atNode:response
                       withNameSpace:nameSpace
                compatibleConstraint:compatibleConstraint];
}

- (NSDictionary *)dictionaryForObject:(id)nodeObject
                               atNode:(QPNetworkingNodeModel *)node
{
    if (!nodeObject) {
        return nil;
    }

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    // 遍历当前节点的所有子节点，生成对应的字典数据。

    NSMutableArray *nodeSubfields = [node objectForKey:QPNetworkingNodeSubfields];
    NSString *stringTypeName = NSStringFromClass([NSString class]);

    for (QPNetworkingFieldModel *field in nodeSubfields) {

        // 提取字段定义信息。

        NSString *fieldName = [field objectForKey:QPNetworkingFieldName];
        NSString *fieldAlias = [field objectForKey:QPNetworkingFieldAlias];
        NSString *fieldType = [self typeNameForField:field withNameSpace:nil];
//      NSString *fieldConstraint = [field objectForKey:QPNetworkingFieldConstraint];
        QPNetworkingNodeModel *fieldNode = [self nodeForField:field];

        // 获取当前字段对应的属性值。

        id value = [nodeObject valueForKey:fieldAlias];
        Class shouldClass = NSClassFromString(fieldType);

        if (value && shouldClass && ![value isKindOfClass:shouldClass]) {
            [NSException raise:QPNetworkingConversionException format:
             @"[QPFoundation] Convert object [%@] to dictionary with "
             @"the field [%@] failed. The field's type should be [%@], "
             @"but actually it is [%@]. Please check your interface definition "
             @"and the value of the node object's properties you assigned.",
             [nodeObject class], fieldName, fieldType, [value class]];
        }

        // 如果属性值是一个数组，则需要对其每个元素进行转换。

        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *subobjects = value;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            value = array;

            for (id subobject in subobjects) {
                id subdictionary = subobject;

                if (fieldNode) {
                    subdictionary = [self dictionaryForObject:subobject
                                                       atNode:fieldNode];
                }

                [array addObject:subdictionary];
            }
        }
        else {
            if (fieldNode) {
                value = [self dictionaryForObject:value
                                           atNode:fieldNode];
            }
            else if (!value
                     && [fieldType isEqualToString:stringTypeName]
                     /* && [fieldConstraint isEqualToString:@"1"] */) {
                value = @"";
            }
        }

        [dictionary setValue:value forKey:fieldName];
    }

    return dictionary;
}

- (id)objectForDictionary:(NSDictionary *)dictionary
                   atNode:(QPNetworkingNodeModel *)node
            withNameSpace:(NSString *)nameSpace
     compatibleConstraint:(BOOL)compatibleConstraint
{
    if (!dictionary) {
        return nil;
    }

    // 提取节点定义信息。

    NSString *nodeName = [node objectForKey:QPNetworkingNodeName];
    NSMutableArray *nodeSubfields = [node objectForKey:QPNetworkingNodeSubfields];

    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        [NSException raise:QPNetworkingConversionException format:
         @"[QPFoundation] Convert dictionary to object at namespace [%@] for "
         @"the node [%@] failed, the dictionary isn't an NSDictionary, "
         @"that the data type is [%@].",
         nameSpace, nodeName, [dictionary class]];
    }

    // 生成当前节点的类名以及子节点对应的模型类的命名空间。

    NSString *className;
    className = [self classNameForNode:node withNameSpace:nameSpace];

    id nodeObject = [[NSClassFromString(className) alloc] init];
    if (!nodeObject) {
        [NSException raise:QPNetworkingConversionException format:
         @"[QPFoundation] Convert dictionary to object at namespace [%@] "
         @"for node [%@] failed, create node object with class [%@] failed.",
         nameSpace, nodeName, className];
    }

    nameSpace = [self nameSpaceForNode:node withNameSpace:nameSpace];

    // 遍历当前节点的所有子节点，生成对应的模型类属性值。

    for (QPNetworkingFieldModel *field in nodeSubfields) {

        // 提取字段定义信息。

        NSString *fieldName = [field objectForKey:QPNetworkingFieldName];
        NSString *fieldAlias = [field objectForKey:QPNetworkingFieldAlias];
        NSString *fieldType = [self typeNameForField:field withNameSpace:nameSpace];
        QPNetworkingNodeModel *fieldNode = [self nodeForField:field];

        // 获取当前字段对应的属性值。

        id value = [dictionary objectForKey:fieldName];

        // 如果当前字段的约束为支持多个，但字典中该节点的值不是数组类型，则有以
        // 下几种情况，根据不同的情况有不同的合理处置方法：
        //   1、对于XML格式转换过来的字典对象，有可能因为子节点只返回一个值，导
        //      致通用的XML转Dictionary模块认为该节点的约束为1，即将数组当成字典
        //      进行处理，对此情况应该予以兼容处理。
        //   2、对于JSON格式转换过来的字典对象，不该产生该问题，应予以报错返回。

        BOOL shouldArray = !!([NSClassFromString(fieldType)
                               isSubclassOfClass:[NSArray class]]);
        BOOL actualArray = !!([value isKindOfClass:[NSArray class]]);

        if (value && shouldArray != actualArray) {
            if (compatibleConstraint) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [array addObject:value];
                value = array;
            }
            else {
                [NSException raise:QPNetworkingConversionException format:
                 @"[QPFoundation] Convert dictionary to object at namespace "
                 @"[%@] for the field [%@] failed. The field's type should be "
                 @"[%@], but actually it is [%@]. Please check your interface "
                 @"definition and the data returned.",
                 nameSpace, fieldName, fieldType, [value class]];
            }
        }

        // 如果当前字段内容出现可能会破坏XML结构的内容，则使用XMLDictionary等第
        // 三方转换库转换XML到NSDictionary时，则可能会将本应解析为字符串的数据，
        // 解析为NSDictionary的情况。所以这里需要添加判断并抛出对应异常信息。

        BOOL shouldString = !!([NSClassFromString(fieldType)
                                isSubclassOfClass:[NSString class]]);
        BOOL actualDictionary = !!([value isKindOfClass:[NSDictionary class]]);

        if (shouldString && actualDictionary) {
            [NSException raise:QPNetworkingConversionException format:
             @"[QPFoundation] Convert dictionary to object at namespace "
             @"[%@] for the field [%@] failed. The field's type should be "
             @"[%@], but actually it is [%@]. Please check your interface "
             @"definition and the data returned.",
             nameSpace, fieldName, fieldType, [value class]];
        }

        // 如果属性值是一个数组，则需要对其每个元素进行转换。

        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *subdictionaries = value;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            value = array;

            for (id subdictionary in subdictionaries) {
                id subobject = subdictionary;

                if (fieldNode) {
                    subobject = [self objectForDictionary:subdictionary
                                                   atNode:fieldNode
                                            withNameSpace:nameSpace
                                     compatibleConstraint:compatibleConstraint];
                }

                [array addObject:subobject];
            }
        }
        else {
            if (fieldNode) {
                value = [self objectForDictionary:value
                                           atNode:fieldNode
                                    withNameSpace:nameSpace
                             compatibleConstraint:compatibleConstraint];
            }
        }

        [nodeObject setValue:value forKey:fieldAlias];
    }

    return nodeObject;
}

@end
