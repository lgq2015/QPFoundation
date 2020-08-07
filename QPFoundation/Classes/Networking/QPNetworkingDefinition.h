//
//  QPNetworkingDefinition.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/24.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


@class QPNetworkingProtocol;


/**
 *  定义保存接口、节点、字段的定义信息的数据类型。
 */
typedef NSMutableDictionary QPNetworkingInterfaceModel;
typedef NSMutableDictionary QPNetworkingNodeModel;
typedef NSMutableDictionary QPNetworkingFieldModel;


/**
 *  接口定义信息。
 */
QP_EXPORT_STRING(QPNetworkingInterfaceName);                        // 接口名称
QP_EXPORT_STRING(QPNetworkingInterfaceAlias);                       // 接口别名
QP_EXPORT_STRING(QPNetworkingInterfaceRequest);                     // 请求报文
QP_EXPORT_STRING(QPNetworkingInterfaceResponse);                    // 应答报文
QP_EXPORT_STRING(QPNetworkingInterfaceRequestContentKeyPath);       // 请求内容
QP_EXPORT_STRING(QPNetworkingInterfaceResponseContentKeyPath);      // 应答内容
QP_EXPORT_STRING(QPNetworkingInterfaceDescription);                 // 描述信息
QP_EXPORT_STRING(QPNetworkingInterfaceFilePath);                    // 定义文件
QP_EXPORT_STRING(QPNetworkingInterfaceLineNumber);                  // 定义行号


/**
 *  节点定义信息。
 */
QP_EXPORT_STRING(QPNetworkingNodeName);                             // 节点名称
QP_EXPORT_STRING(QPNetworkingNodeAlias);                            // 节点别名
QP_EXPORT_STRING(QPNetworkingNodeSubfields);                        // 子项数组
QP_EXPORT_STRING(QPNetworkingNodeIndependent);                      // 独立节点
QP_EXPORT_STRING(QPNetworkingNodeCallback);                         // 回调方法
QP_EXPORT_STRING(QPNetworkingNodeDescription);                      // 描述信息


/**
 *  字段定义信息。
 */
QP_EXPORT_STRING(QPNetworkingFieldName);                            // 字段名称
QP_EXPORT_STRING(QPNetworkingFieldAlias);                           // 字段别名
QP_EXPORT_STRING(QPNetworkingFieldOuterNode);                       // 外部节点
QP_EXPORT_STRING(QPNetworkingFieldConstraint);                      // 个数约束
QP_EXPORT_STRING(QPNetworkingFieldSubfields);                       // 子项数组
QP_EXPORT_STRING(QPNetworkingFieldCallback);                        // 回调方法
QP_EXPORT_STRING(QPNetworkingFieldDescription);                     // 描述信息


/**
 *  当前正在定义的节点。仅在协议定义宏内部使用。
 */
FOUNDATION_EXPORT __unsafe_unretained QPNetworkingNodeModel *QPNetworkingCurrentNode;


/**
 *  协议定义异常。
 */
QP_EXPORT_KEYNAME(QPNetworkingProtocolException);


#pragma mark - 协议上下文。

/**
 *  获取协议上下文的堆栈。协议定义宏所定义的接口/节点/字段等内容均会被添加到当前
 *  位于栈顶的协议上下文中。一般仅在框架内部使用。
 */
FOUNDATION_EXPORT
NSMutableArray *
QPNetworkingGetProtocolContextStack(void);

/**
 *  获取当前位于栈顶的协议上下文。一般仅在框架内部使用。
 */
FOUNDATION_EXPORT
QPNetworkingProtocol *
QPNetworkingGetCurrentProtocolContext(void);

/**
 *  将协议上下文压入堆栈的栈顶。一般仅在框架内部使用。
 */
FOUNDATION_EXPORT
void
QPNetworkingPushProtocolContext(QPNetworkingProtocol *context);

/**
 *  将当前位于栈顶的协议上下文弹出堆栈。一般仅在框架内部使用。
 */
FOUNDATION_EXPORT
void
QPNetworkingPopProtocolContext(void);


#pragma mark - 协议创建函数。

/**
 *  创建接口。一般不直接调用，而是通过协议定义宏间接调用。
 */
FOUNDATION_EXPORT
QPNetworkingInterfaceModel *
QPNetworkingCreateInterface(NSString *name,
                            NSString *alias,
                            QPNetworkingNodeModel *request,
                            NSString *requestContentKeyPath,
                            QPNetworkingNodeModel *response,
                            NSString *responseContentKeyPath,
                            NSString *description,
                            NSString *filePath,
                            NSUInteger lineNumber);

/**
 *  创建独立节点。一般不直接调用，而是通过协议定义宏间接调用。
 */
FOUNDATION_EXPORT
QPNetworkingNodeModel *
QPNetworkingCreateIndependentNode(NSString *name,
                                  NSString *alias,
                                  SEL callback,
                                  NSString *description);

/**
 *  创建临时节点。一般不直接调用，而是通过协议定义宏间接调用。
 */
FOUNDATION_EXPORT
QPNetworkingNodeModel *
QPNetworkingCreateTemporaryNode(NSString *name);

/**
 *  创建字段。一般不直接调用，而是通过协议定义宏间接调用。
 */
FOUNDATION_EXPORT
QPNetworkingFieldModel *
QPNetworkingCreateField(QPNetworkingFieldModel *parentField,
                        NSString *name,
                        NSString *alias,
                        QPNetworkingNodeModel *outerNode,
                        NSString *constraint,
                        SEL callback,
                        NSString *description);


#pragma mark - 协议定义宏。

/**
 *  当前作用域内有效的接口定义字典变量名。仅在协议定义宏内部使用。
 */
#define QPNetworkingInterfaceVariable(name)     __QPNetworkingInterface__##name

/**
 *  当前作用域内有效的节点定义字典变量名。仅在协议定义宏内部使用。
 */
#define QPNetworkingNodeVariable(name)          __QPNetworkingNode__##name

/**
 *  当前作用域内有效的字段定义字典变量名。仅在协议定义宏内部使用。
 */
#define QPNetworkingFieldVariable(name)         __QPNetworkingField__##name


#pragma mark - 定义字段。

/**
 *  定义字段。
 *
 *  @param parent_alias  父字段别名。
 *  @param name          字段名称，即在请求报文/应答报文中该字段的名称。
 *  @param alias         字段别名，代码在需要引用该字段时，会将其别名作为标识符
 *                       使用。默认与字段名称一致。
 *  @param outer_node    外部节点，可为nil。当使用时，会将外部节点的所有子节点引
 *                       作当前字段的子节点。
 *  @param constraint    字段的个数约束，支持下面几种约束类型：
 *                         ?       最多只有一个；
 *                         +       最少会有一个；
 *                         *       个数不限；
 *                         1       有且只有一个。
 *  @param callback      由协议对象所提供的回调方法，可为nil。用于在接口请求前或
 *                       响应后对字段进行校验或修改等定制化处理。
 *  @param ...           描述信息，在创建的接口模型类中用作字段的注释。
 */
#define QPNetworkingFieldX(parent_alias, name, alias, outer_node, constraint, callback, ...) \
    QPNetworkingFieldModel *QPNetworkingFieldVariable(alias) = QPNetworkingCreateField( \
        QPNetworkingFieldVariable(parent_alias), \
        QPLiteralness(name), \
        QPLiteralness(alias), \
        (outer_node), \
        QPLiteralness(constraint), \
        (callback), \
        QPLiteralness(__VA_ARGS__) \
    ); \
    [QPNetworkingFieldVariable(alias) self]

#define QPNetworkingField(parent_alias, name, constraint, ...) \
    QPNetworkingFieldX(parent_alias, name, name, nil, \
                       constraint, nil, __VA_ARGS__)

#define QPNetworkingAlias(parent_alias, name, alias, constraint, ...) \
    QPNetworkingFieldX(parent_alias, name, alias, nil, \
                       constraint, nil, __VA_ARGS__)

#define QPNetworkingQuoteX(parent_alias, name, alias, outer_node_alias, constraint, callback, ...) \
    QPNetworkingFieldX(parent_alias, name, alias, \
                       QPNetworkingNodeVariable(outer_node_alias), \
                       constraint, callback, __VA_ARGS__)

#define QPNetworkingQuote(parent_alias, name, constraint, ...) \
    QPNetworkingQuoteX(parent_alias, name, name, name, \
                       constraint, nil, __VA_ARGS__)


#pragma mark - 定义独立节点。

/**
 *  定义独立节点。
 *
 *  @param name     节点名称，仅用于定义子节点时引用为父节点，不会在报文中使用。
 *  @param alias    节点别名，在创建的接口模型类中用作节点模型类的独立的类名称。
 *  @param callback 由协议对象所提供的回调方法，可为nil。用于在接口请求前或响应
 *                  后对节点进行校验或修改等定制化处理。
 *  @param ...      描述信息，在创建的接口模型类中用作节点的注释。
 */
#define QPNetworkingIndependentNodeBegin(name, alias, callback, ...) \
    QPNetworkingNodeModel *QPNetworkingNodeVariable(alias) = QPNetworkingCreateIndependentNode( \
        QPLiteralness(name), \
        QPLiteralness(alias), \
        (callback), \
        QPLiteralness(__VA_ARGS__) \
    ); \
    QPNetworkingCurrentNode = QPNetworkingNodeVariable(alias); \
    do { \
        QPNetworkingFieldModel *QPNetworkingFieldVariable(name) = nil; \
        QPNetworkingFieldVariable(name) = QPNetworkingCurrentNode

#define QPNetworkingIndependentNodeEnd() \
    } while (0); \
    [QPNetworkingCurrentNode self]


#pragma mark - 定义临时节点。

/**
 *  定义临时节点。临时节点主要用于将接口协议进行分段定义，特别是当两个不同父节点
 *  下有相同名称的字段而产生命名冲突时，可用临时节点将两个父节点分开进行定义，这
 *  样两个父节点内的所有子节点是在两个不同的命名空间中出现的，所以不会产生命名冲
 *  突的问题。临时节点没有独立的节点模型，都是与具体接口相关的。
 *
 *  @param name    节点名称，仅用于接口协议定义时标识该节点，不会在报文中使用。
 */
#define QPNetworkingTemporaryNodeBegin(name) \
    QPNetworkingNodeModel *QPNetworkingNodeVariable(name) = QPNetworkingCreateTemporaryNode( \
        QPLiteralness(name) \
    ); \
    QPNetworkingCurrentNode = QPNetworkingNodeVariable(name); \
    do { \
        QPNetworkingFieldModel *QPNetworkingFieldVariable(name) = nil; \
        QPNetworkingFieldVariable(name) = QPNetworkingCurrentNode

#define QPNetworkingTemporaryNodeEnd() \
    } while (0); \
    [QPNetworkingCurrentNode self]

#define QPNetworkingNodeBegin(name) \
    QPNetworkingTemporaryNodeBegin(name)

#define QPNetworkingNodeEnd() \
    QPNetworkingTemporaryNodeEnd()


#pragma mark - 定义接口。

/**
 *  定义接口。
 *
 *  @param name                       接口名称，即在请求报文/应答报文中使用到的
 *                                    接口标识名称。
 *  @param alias                      接口别名，在创建的接口模型类以及接口调用函
 *                                    数中使用。
 *  @param request                    请求报文节点。
 *  @param request_content_key_path   请求报文节点中请求内容的key-path，用于简化
 *                                    接口调用函数的编写。可为nil值。
 *  @param response                   应答报文节点。
 *  @param response_content_key_path  应答报文节点中应答内容的key-path，用于简化
 *                                    接口调用函数的编写。可为nil值。
 *  @param ...                        描述信息，在创建的接口调用函数中用作接口的
 *                                    注释。
 */
#define QPNetworkingInterface(name, alias, request, request_content_key_path, response, response_content_key_path, ...) \
    QPNetworkingInterfaceModel *QPNetworkingInterfaceVariable(alias) = QPNetworkingCreateInterface( \
        QPLiteralness(name), \
        QPLiteralness(alias), \
        (request), \
        QPLiteralness(request_content_key_path), \
        (response), \
        QPLiteralness(response_content_key_path), \
        QPLiteralness(__VA_ARGS__), \
        [NSString stringWithUTF8String:__FILE__], \
        __LINE__ \
    ); \
    [QPNetworkingInterfaceVariable(alias) self]
