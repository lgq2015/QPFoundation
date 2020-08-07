//
//  NSObject+Dump.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/4/22.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  判断指定地址是否是一个对象实例的地址。
 *
 *  @param address 内存地址。
 *
 *  @return 如果内存地址指向的是一个对象实例，则返回YES，否则返回NO。
 */
FOUNDATION_EXPORT BOOL ODIsAnObject(void *address);


/**
 *  返回类的所有属性的信息。
 *
 *  @param classObject 类对象。
 *
 *  @return 返回一个由类的所有属性的参数字典组成的数组。
 */
FOUNDATION_EXPORT NSArray *ODGetClassProperties(Class classObject);


/**
 *  属性的各种参数，用于获取属性列表时作为属性字典的Key。
 */
FOUNDATION_EXPORT NSString *const CSPropertyName;       // 属性名称。
FOUNDATION_EXPORT NSString *const CSPropertyHost;       // 属性宿主（所属类）。
FOUNDATION_EXPORT NSString *const CSPropertyType;       // 属性类型。
FOUNDATION_EXPORT NSString *const CSPropertyGetter;     // 属性Getter。
FOUNDATION_EXPORT NSString *const CSPropertyOffset;     // 实例变量偏移。


/**
 *  对象转储选项。
 */
typedef NS_OPTIONS(NSUInteger, ODDumpOptions) {
    ODDumpSelf = 0,                     // 转储对象自身信息。
    ODDumpSuper = 1,                    // 转储来自父类的信息。
    ODDumpSystem = 2,                   // 转储来自系统类的信息。
    ODDumpSortMembers = 4,              // 转储时对对象成员进行排序。
    ODDumpFirstOnly = 8,                // 同一个对象，仅转储第一次出现的地方。
    ODDumpTypeClear = 16,               // 仅转储类型明确的对象（即忽略id类型）。
    ODDumpNonemptyPointerOnly = 32,     // 仅转储非空指针的值（包括对象）。
    ODDumpNondefaultValueOnly = 64      // 仅转储非缺省的值。
};


@interface NSObject (Dump)

/**
 *  转储对象的关键信息。
 */
- (NSString *)dump;

/**
 *  转储对象的关键信息，但限制转储的最大层数。
 */
- (NSString *)dump:(NSUInteger)maxDepth;

/**
 *  转储对象的详细信息。
 */
- (NSString *)dumpDetail;

/**
 *  转储对象的所有信息。
 */
- (NSString *)dumpAll;

/**
 *  转储对象信息。
 *
 *  @param options   对象转储选项。
 *  @param maxDepth  最大转储深度。
 *  @param maxLength 最大转储长度。
 *
 *  @return 返回转储的信息。
 */
- (NSString *)dumpWithOptions:(ODDumpOptions)options
                     maxDepth:(NSUInteger)maxDepth
                    maxLength:(NSUInteger)maxLength;

@end
