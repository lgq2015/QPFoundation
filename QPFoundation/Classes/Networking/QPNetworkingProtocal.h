//
//  QPNetworkingProtocal.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/28.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  定义保存接口调用函数、节点模型类、字段属性的定义信息的数据类型。
 */
typedef NSMutableDictionary QPNetworkingInterfaceInvokeModel;
typedef NSMutableDictionary QPNetworkingNodeClassModel;
typedef NSMutableDictionary QPNetworkingFieldPropertyModel;


/**
 *  接口调用函数定义信息。
 */
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeName);                      // 接口名称
QP_EXPORT_STRING(QPNetworkingInterfaceEnhancedInvokeName);              // 增强版本
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeAlias);                     // 接口别名
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeRequestClassName);          // 请求报文
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeResponseClassName);         // 应答报文
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeRequestContentKeyPath);     // 请求内容
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeResponseContentKeyPath);    // 应答内容
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeRequestContentClassName);   // 请求内容
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeResponseContentClassName);  // 应答内容
QP_EXPORT_STRING(QPNetworkingInterfaceInvokeComments);                  // 接口注释


/**
 *  节点模型类定义信息。
 */
QP_EXPORT_STRING(QPNetworkingNodeClassName);                            // 模型名称
QP_EXPORT_STRING(QPNetworkingNodeClassProperties);                      // 属性列表
QP_EXPORT_STRING(QPNetworkingNodeClassComments);                        // 模型注释


/**
 *  字段属性定义信息。
 */
QP_EXPORT_STRING(QPNetworkingFieldPropertyName);                        // 属性名称
QP_EXPORT_STRING(QPNetworkingFieldPropertyTypeName);                    // 属性类型
QP_EXPORT_STRING(QPNetworkingFieldPropertyClassName);                   // 属性类名
QP_EXPORT_STRING(QPNetworkingFieldPropertyComments);                    // 属性注释


/**
 *  网络协议抽象基类，子类应该重写initializeInterfaces方法定义协议涉及的接口。
 */
@interface QPNetworkingProtocal : NSObject

/**
 *  协议名称，用于向框架注册时标识该协议，并且也是默认的根命名空间，用于协议产生
 *  的所有接口调用函数、节点模型类等的前缀。建议使用有意义的缩写，如CRM、ESOP等。
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  协议绑定的网络操作类，所有协议涉及的接口都使用该操作类进行网络请求处理。在接
 *  口调用时会生成该操作类的实例，并设置请求及响应所需的数据及回调，最终提交到全
 *  局的网络请求队列中，由操作类完成网络请求任务。
 *
 *  @see QPNetworkingOperation
 */
@property (nonatomic, copy) NSString *operationClassName;

/**
 *  初始化协议对象，并绑定协议名称及网络操作类。
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  初始化接口协议，默认什么也不做。子类应该重写该方法，并在其中使用协议定义宏将
 *  所有该协议涉及的接口都定义出来。如果定义时使用了callback回调方法，还需要在子
 *  类上实现对应的回调方法。
 */
- (void)initializeInterfaces;


#pragma mark - 接口协议管理。

- (NSArray *)allInterfaceAliases;
- (NSArray *)allNodeAliases;
- (QPNetworkingInterfaceModel *)interfaceWithAlias:alias;
- (QPNetworkingNodeModel *)nodeWithAlias:alias;


#pragma mark - 接口协议编程。

- (NSString *)nameSpace;

- (NSString *)nameSpaceForInterface:(QPNetworkingInterfaceModel *)interface;

- (NSString *)nameSpaceForInterface:(QPNetworkingInterfaceModel *)interface
                      withNameSpace:(NSString *)nameSpace;

- (NSString *)nameSpaceForNode:(QPNetworkingNodeModel *)node
                 withNameSpace:(NSString *)nameSpace;

- (NSString *)nameSpaceForKey:(NSString *)key
                       atNode:(QPNetworkingNodeModel *)node
                withNameSpace:(NSString *)nameSpace;

- (NSString *)nameSpaceForKeyPath:(NSString *)keyPath
                           atNode:(QPNetworkingNodeModel *)node
                    withNameSpace:(NSString *)nameSpace;

- (NSString *)operationName;

- (NSString *)invokeNameForInterface:(QPNetworkingInterfaceModel *)interface;

- (NSString *)invokeNameForInterface:(QPNetworkingInterfaceModel *)interface
                       withNameSpace:(NSString *)nameSpace;

- (NSString *)enhancedInvokeNameForInterface:(QPNetworkingInterfaceModel *)interface;

- (NSString *)enhancedInvokeNameForInterface:(QPNetworkingInterfaceModel *)interface
                               withNameSpace:(NSString *)nameSpace;

- (NSString *)classNameForRequestOfInterface:(QPNetworkingInterfaceModel *)interface;

- (NSString *)classNameForResponseOfInterface:(QPNetworkingInterfaceModel *)interface;

- (NSString *)classNameForRequestOfInterface:(QPNetworkingInterfaceModel *)interface
                               withNameSpace:(NSString *)nameSpace;

- (NSString *)classNameForResponseOfInterface:(QPNetworkingInterfaceModel *)interface
                                withNameSpace:(NSString *)nameSpace;

- (NSString *)classNameForNode:(QPNetworkingNodeModel *)node
                 withNameSpace:(NSString *)nameSpace;

- (NSString *)classNameForField:(QPNetworkingFieldModel *)field
                  withNameSpace:(NSString *)nameSpace;

- (NSString *)classNameForKey:(NSString *)key
                       atNode:(QPNetworkingNodeModel *)node
                withNameSpace:(NSString *)nameSpace;

- (NSString *)classNameForKeyPath:(NSString *)keyPath
                           atNode:(QPNetworkingNodeModel *)node
                    withNameSpace:(NSString *)nameSpace;

- (NSString *)typeNameForField:(QPNetworkingFieldModel *)field
                 withNameSpace:(NSString *)nameSpace;

- (NSString *)typeNameForKey:(NSString *)key
                      atNode:(QPNetworkingNodeModel *)node
               withNameSpace:(NSString *)nameSpace;

- (NSString *)typeNameForKeyPath:(NSString *)keyPath
                          atNode:(QPNetworkingNodeModel *)node
                   withNameSpace:(NSString *)nameSpace;

- (QPNetworkingNodeModel *)nodeForRequestOfInterface:(QPNetworkingInterfaceModel *)interface;

- (QPNetworkingNodeModel *)nodeForResponseOfInterface:(QPNetworkingInterfaceModel *)interface;

- (QPNetworkingNodeModel *)nodeForField:(QPNetworkingFieldModel *)field;

- (QPNetworkingNodeModel *)nodeForKey:(NSString *)key
                               atNode:(QPNetworkingNodeModel *)node;

- (QPNetworkingNodeModel *)nodeForKeyPath:(NSString *)keyPath
                                   atNode:(QPNetworkingNodeModel *)node;

- (QPNetworkingFieldModel *)fieldForKey:(NSString *)key
                                 atNode:(QPNetworkingNodeModel *)node;

- (QPNetworkingFieldModel *)fieldForKeyPath:(NSString *)keyPath
                                     atNode:(QPNetworkingNodeModel *)node;


#pragma mark - 接口协议生成。

/**
 *  编译协议涉及的所有接口、独立节点等，生成用于支撑网络框架的各类文件。
 */
- (void)compile;

/**
 *  针对编译结果，生成具体的用于支撑网络框架的各类文件。
 */
- (void)link;

/**
 *  将协议涉及需要生成的模型类及接口调用方法等代码文件生成到默认目录中。默认什么
 *  也不做，子类可以重写该方法，使得接口生成管理程序可以进行统一的调用。
 */
- (void)make;

/**
 *  将协议涉及需要生成的模型类及接口调用方法等代码文件生成到指定目录中。
 *
 *  @note 由于生成的是代码文件，所以需要在Mac OS X系统中调用才有意义。
 */
- (void)makeToDirectory:(NSString *)directory;


#pragma mark - 接口测试桩生成。

/**
 *  将协议涉及的所有接口的返回报文的测试桩文件生成到默认目录中。默认什么也不做，
 *  子类可以重写该方法，使得接口生成管理程序可以进行统一的调用。
 */
- (void)stub;

/**
 *  将协议涉及的所有接口的返回报文的测试桩文件生成到指定目录中。
 *
 *  @note 由于生成的是测试桩文件，所以需要在Mac OS X系统中调用才有意义。
 */
- (void)stubToDirectory:(NSString *)directory;

/**
 *  返回接口对应的测试桩文件的名称，默认为<interface-name>.json。
 */
- (NSString *)stubNameForInterface:(QPNetworkingInterfaceModel *)interface;

/**
 *  返回接口对应的测试桩文件的内容，默认为JSON格式。
 */
- (NSData *)stubDataForInterface:(QPNetworkingInterfaceModel *)interface;

/**
 *  返回接口对应的返回报文的测试桩对象（Foundation Objects）。
 */
- (id)stubObjectForInterface:(QPNetworkingInterfaceModel *)interface;

/**
 *  返回节点对应的测试桩对象（Foundation Objects）。
 */
- (id)stubObjectForNode:(QPNetworkingNodeModel *)node;

/**
 *  返回字段对应的测试桩对象（Foundation Objects）。
 */
- (id)stubObjectForField:(QPNetworkingFieldModel *)field;


#pragma mark - 接口协议回调。

/**
 *  针对接口的请求报文进行回调处理。
 */
- (id)callbackForRequest:(id)requestObject
             atInterface:(QPNetworkingInterfaceModel *)interface
              withSender:(id)sender;

/**
 *  针对接口的返回报文进行回调处理。
 */
- (id)callbackForResponse:(id)responseObject
              atInterface:(QPNetworkingInterfaceModel *)interface
               withSender:(id)sender;

/**
 *  针对节点的对象进行回调处理，回调方法以协议类的实例方法体现，格式如下：
 *      - (<节点模型类类名> *)callback:(<节点模型类类名> *)nodeObject;
 *  回调方法中可以修改nodeObject成员的值并返回nodeObject本身，也可以重新生成一个
 *  全新的节点模型类实例返回。
 */
- (id)callbackForObject:(id)nodeObject
                 atNode:(QPNetworkingNodeModel *)node
             withSender:(id)sender;


#pragma mark - 接口协议转换。

/**
 *  将请求报文转换为Foundation Objects，然后配合JSONKit/XMLDictionary来转换成网
 *  络请求规定的报文格式。
 */
- (NSDictionary *)dictionaryForRequest:(id)requestObject
                           atInterface:(QPNetworkingInterfaceModel *)interface;

/**
 *  将Foundation Objects转换为应答报文。通常在网络请求返回时，将收到的返回报文使
 *  用JSONKit/XMLDictionary转换成Foundation Objects，然后再调用该方法转换成网络
 *  框架使用的接口返回报文对象。
 */
- (id)responseForDictionary:(NSDictionary *)dictionary
                atInterface:(QPNetworkingInterfaceModel *)interface
       compatibleConstraint:(BOOL)compatibleConstraint;

/**
 *  将节点模型类实例转换为Foundation Objects。
 */
- (NSDictionary *)dictionaryForObject:(id)nodeObject
                               atNode:(QPNetworkingNodeModel *)node;

/**
 *  将Foundation Objects转换为节点模型类实例。
 */
- (id)objectForDictionary:(NSDictionary *)dictionary
                   atNode:(QPNetworkingNodeModel *)node
            withNameSpace:(NSString *)nameSpace
     compatibleConstraint:(BOOL)compatibleConstraint;

@end
