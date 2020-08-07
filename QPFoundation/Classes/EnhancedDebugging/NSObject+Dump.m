//
//  NSObject+Dump.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/4/22.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSObject+Dump.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <CoreGraphics/CoreGraphics.h>
#endif
#import <objc/message.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <malloc/malloc.h>


/**
 *  属性的各种参数，用于获取属性列表时作为属性字典的Key。
 */
NSString *const CSPropertyName = @"Name";       // 属性名称。
NSString *const CSPropertyHost = @"Host";       // 属性宿主（所属类）。
NSString *const CSPropertyType = @"Type";       // 属性类型。
NSString *const CSPropertyGetter = @"Getter";   // 属性Getter。
NSString *const CSPropertyOffset = @"Offset";   // 实例变量偏移。


/**
 *  转储属性的值，针对不同的数据类型，将其返回值转换为对应的值。
 */
#define ODDumpPropertyBegin() \
    if (getter && !(options & ODDumpSystem)) { \
        NSDictionary *systemProperties = nil; \
        systemProperties = @{@"dump":@"", \
                            @"dumpDetail":@"", \
                            @"description":@"", \
                            @"debugDescription":@"", \
                            @"hash":@"", \
                            @"__content":@"", \
                            @"_responderForEditing":@"", \
                            @"_textSelectingContainer":@""}; \
        if ([systemProperties objectForKey:name]) { \
            continue; \
        } \
    } \
    if (!offset && ![self respondsToSelector:SEL_getter]) { \
        continue; \
    } \
    NSDictionary *crashProperties = nil; \
    crashProperties = @{@"UIWheelEvent:subtype":@"", \
                        @"UIPhysicalKeyboardEvent:_keyCode":@""}; \
    if ([crashProperties objectForKey:[NSString stringWithFormat:@"%@:%@", class, name]]) { \
        continue; \
    } \
    if ([@"caretRect" isEqualToString:name] \
        && ![[self class] conformsToProtocol:NSProtocolFromString(@"UITextInput")]) { \
        continue; \
    } \

#define ODDumpProtoProperty(_type, _format) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = 0; \
        _type defaultValue = 0; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            returnValue = ((_type (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) && (returnValue == defaultValue)) { \
            continue; \
        } \
        if ((options & ODDumpNonemptyPointerOnly) && ('^' == *encode) && !returnValue) { \
            continue; \
        } \
        value = [NSString stringWithFormat:(_format), returnValue]; \
    } \

#define ODDumpValueProperty(_type, _value) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = 0; \
        _type defaultValue = 0; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            returnValue = ((_type (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) && (returnValue == defaultValue)) { \
            continue; \
        } \
        if ((options & ODDumpNonemptyPointerOnly) && ('^' == *encode) && !returnValue) { \
            continue; \
        } \
        value = (_value); \
    } \

#if defined(__arm__) || defined(__arm64__)

/**
 *  在32/64位arm指令集上，不支持objc_msgSend_fpret调用。
 */
#define ODDumpFloatProperty(_type, _format) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = 0; \
        _type defaultValue = 0; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            returnValue = ((_type (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) && (returnValue == defaultValue)) { \
            continue; \
        } \
        if ((options & ODDumpNonemptyPointerOnly) && ('^' == *encode) && !returnValue) { \
            continue; \
        } \
        value = [NSString stringWithFormat:(_format), returnValue]; \
        if ([value rangeOfString:@"."].location != NSNotFound) { \
            value = [value stringByReplacingOccurrencesOfString:@"[0]*$" \
                                                     withString:@"" \
                                                        options:NSRegularExpressionSearch \
                                                          range:NSMakeRange(0, [value length])]; \
            value = [value stringByReplacingOccurrencesOfString:@"[.]$" \
                                                     withString:@".0" \
                                                        options:NSRegularExpressionSearch \
                                                          range:NSMakeRange(0, [value length])]; \
        }\
        if ([value length] >= 20) { \
            value = [NSString stringWithFormat:@"%Le", (long double)returnValue]; \
        } \
    } \

#else

/**
 *  在32/64位x86指令集上，objc_msgSend_fpret的返回类型固定是double。
 */
#define ODDumpFloatProperty(_type, _format) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = 0; \
        _type defaultValue = 0; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            returnValue = (_type)((double (*)(id, SEL))objc_msgSend_fpret)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) && (returnValue == defaultValue)) { \
            continue; \
        } \
        if ((options & ODDumpNonemptyPointerOnly) && ('^' == *encode) && !returnValue) { \
            continue; \
        } \
        value = [NSString stringWithFormat:(_format), returnValue]; \
        if ([value rangeOfString:@"."].location != NSNotFound) { \
            value = [value stringByReplacingOccurrencesOfString:@"[0]*$" \
                                                     withString:@"" \
                                                        options:NSRegularExpressionSearch \
                                                          range:NSMakeRange(0, [value length])]; \
            value = [value stringByReplacingOccurrencesOfString:@"[.]$" \
                                                     withString:@".0" \
                                                        options:NSRegularExpressionSearch \
                                                          range:NSMakeRange(0, [value length])]; \
        }\
        if ([value length] >= 20) { \
            value = [NSString stringWithFormat:@"%Le", (long double)returnValue]; \
        } \
    } \

#endif

#if defined(__arm__)

/**
 *  在32位arm指令集上，支持objc_msgSend_stret调用。
 */
#define ODDumpStructProperty(_type, _value) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = {0}; \
        _type defaultValue = {0}; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            ((void (*)(void *, id, SEL))objc_msgSend_stret)(&returnValue, self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) \
            && !memcmp(&returnValue, &defaultValue, sizeof(_type))) { \
            continue; \
        } \
        value = [(@"(" #_type @")") stringByAppendingString:(_value)]; \
    } \

#elif defined(__arm64__)

/**
 *  在64位arm指令集上，不支持objc_msgSend_stret调用。
 */
#define ODDumpStructProperty(_type, _value) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = {0}; \
        _type defaultValue = {0}; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            returnValue = ((_type (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) \
            && !memcmp(&returnValue, &defaultValue, sizeof(_type))) { \
            continue; \
        } \
        value = [(@"(" #_type @")") stringByAppendingString:(_value)]; \
    } \

#elif defined(__i386__)

/**
 *  在32位x86指令集上，调用objc_msgSend_stret后，需要将寄存器esp再减去4字节。
 */
#define ODDumpStructProperty(_type, _value) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = {0}; \
        _type defaultValue = {0}; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            if (sizeof(_type) <= sizeof(CGPoint)) { \
                returnValue = ((_type (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
            } else { \
                ((void (*)(void *, id, SEL))objc_msgSend_stret)(&returnValue, self, SEL_getter); \
                __asm__("subl $4, %esp");\
            } \
        } \
        if ((options & ODDumpNondefaultValueOnly) \
            && !memcmp(&returnValue, &defaultValue, sizeof(_type))) { \
            continue; \
        } \
        value = [(@"(" #_type @")") stringByAppendingString:(_value)]; \
    } \

#elif defined(__x86_64__)

/**
 *  在64位x86指令集上，调用objc_msgSend_stret后，不需要作作何特殊处理。
 */
#define ODDumpStructProperty(_type, _value) \
    else if (0 == strcmp(encode, @encode(_type))) { \
        _type returnValue = {0}; \
        _type defaultValue = {0}; \
        if (offset) { \
            returnValue = *(_type *)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            if (sizeof(_type) <= sizeof(CGPoint)) { \
                returnValue = ((_type (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
            } else { \
                ((void (*)(void *, id, SEL))objc_msgSend_stret)(&returnValue, self, SEL_getter); \
            } \
        } \
        if ((options & ODDumpNondefaultValueOnly) \
            && !memcmp(&returnValue, &defaultValue, sizeof(_type))) { \
            continue; \
        } \
        value = [(@"(" #_type @")") stringByAppendingString:(_value)]; \
    } \

#endif

#define ODDumpObjectProperty() \
    else if ('@' == *encode) { \
        BOOL isBadObject = NO; \
        id returnValue; \
        if (offset) { \
            void *pointer = *(void **)((__bridge void *)self + offset.unsignedIntValue); \
            if (pointer && (isBadObject = !ODIsAnObject(pointer))) { \
                returnValue = [NSString stringWithFormat:@"(exception:*** The pointer %p maybe not an object. ***)", pointer]; \
            } else { \
                returnValue = (__bridge id)pointer; \
            } \
        } else { \
            returnValue = ((id (*)(id, SEL))objc_msgSend)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) && !returnValue) { \
            continue; \
        } \
        if ((options & ODDumpNonemptyPointerOnly) && !returnValue) { \
            continue; \
        } \
        if (![returnValue isKindOfClass:[NSString class]] || isBadObject) { \
            NSString *typename = type; \
            typename = [typename stringByReplacingOccurrencesOfString:@"@" \
                                                           withString:@""]; \
            typename = [typename stringByReplacingOccurrencesOfString:@"\"" \
                                                           withString:@""]; \
            if ([typename length] <= 0) { \
                typename = @"id"; \
            } else if (0 == [typename rangeOfString:@"<"].location) { \
                typename = [@"id" stringByAppendingString:typename]; \
            } else if (0 == [typename rangeOfString:@"?"].location) { \
                typename = @"block"; \
            } else { \
                typename = [typename stringByAppendingString:@" *"]; \
            } \
            key = [key stringByAppendingFormat:@"(%@)", typename]; \
            value = returnValue; \
        } else { \
            value = [returnValue dumpAtomObject]; \
        } \
    } \

#define ODDumpPropertyEnd() \
    else if ('^' == *encode) { \
        void *returnValue; \
        if (offset) { \
            returnValue = *(void **)((__bridge void *)self + offset.unsignedIntValue); \
        } else { \
            returnValue = ((void *(*)(id, SEL))objc_msgSend)(self, SEL_getter); \
        } \
        if ((options & ODDumpNondefaultValueOnly) && !returnValue) { \
            continue; \
        } \
        if ((options & ODDumpNonemptyPointerOnly) && !returnValue) { \
            continue; \
        } \
        if (0 == strcmp(encode, @encode(void (*)(void)))) { \
            value = [NSString stringWithFormat:@"(function)<%p>", returnValue]; \
        } else { \
            value = [NSString stringWithFormat:@"(%s)<%p>", encode, returnValue]; \
        } \
    } else { \
        value = [NSString stringWithFormat: \
                 @"(exception:*** Unsupported type (%s). ***)", encode]; \
    } \
    if (!value) { \
        value = @"(null)"; \
    } \


// 判断指定地址是否是一个对象实例的地址。
BOOL ODIsAnObject(void *address) {
    void **instance = (void **)address;
    void **class = NULL;
    void **metaclass = NULL;
    void **nsobject = NULL;
    void **nsobject_self = NULL;

    // 校验instance->class的isa指向是否有效。

    void *constant = (__bridge void *)@"_";
    void *min = address < constant ? address : constant;
    void *max = address > constant ? address : constant;

    if (instance && (!madvise(min, max - min + sizeof(void *), MADV_NORMAL)
        || malloc_size(instance) >= sizeof(void *))) {
        class = *instance;
    }

    // 校验class->metaclass的isa指向是否有效。

    if (class && !madvise(class, sizeof(void *), MADV_NORMAL)) {
        metaclass = *class;
    }

    // 校验metaclass->NSObject的isa指向是否有效。

    if (metaclass && !madvise(metaclass, sizeof(void *), MADV_NORMAL)) {
        nsobject = *metaclass;
    }

    // 校验NSObject->NSObject的isa自指向是否有效。

    if (nsobject && !madvise(nsobject, sizeof(void *), MADV_NORMAL)) {
        nsobject_self = *nsobject;
        if (nsobject_self != nsobject) {
            return NO;
        }
    }

    return (*(void ***)(__bridge void *)[NSObject class] == nsobject_self);
}


// 返回类的所有属性的信息。
NSArray *ODGetClassProperties(Class class)
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSString *propertyHost = NSStringFromClass(class);

    // 优先添加父类的属性列表。

    if ([NSObject class] != class) {
        [array addObjectsFromArray:
         ODGetClassProperties(class_getSuperclass(class))];
    }

    // 遍历属性列表，将各属性信息保存到字典，并放入返回数组。

    unsigned int propertyCount = 0;
    objc_property_t *properties = NULL;
    properties = class_copyPropertyList(class, &propertyCount);

    NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:0];
    for (int i = 0; i < propertyCount; ++i) {

        // 遍历参数列表，取出当前属性的关键参数。

        unsigned int attributeCount = 0;
        objc_property_attribute_t *attributes = NULL;
        attributes = property_copyAttributeList(properties[i], &attributeCount);

        const char *name = property_getName(properties[i]);
        const char *type = NULL;
        const char *getter = NULL;
        const char *variable = NULL;

        for (unsigned int j = 0; j < attributeCount; ++j) {
            if (0 == strcmp(attributes[j].name, "T")) {         // 类型
                type = attributes[j].value;
            }
            else if (0 == strcmp(attributes[j].name, "G")) {    // getter
                getter = attributes[j].value;
            }
            else if (0 == strcmp(attributes[j].name, "V")) {    // 变量
                variable = attributes[j].value;
            }
        }

        if (!getter || !*getter) {
            getter = name;
        }

        // 将属性的参数保存到字典，并放入返回数组中。

        NSString *propertyName = [NSString stringWithCString:name
                                                    encoding:NSASCIIStringEncoding];
        NSString *propertyType = [NSString stringWithCString:type
                                                    encoding:NSASCIIStringEncoding];
        NSString *propertyGetter = [NSString stringWithCString:getter
                                                      encoding:NSASCIIStringEncoding];

        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyGetter}];

        // 将属性所绑定的实例变量名称放入variables字典，用于后面判断是否是属性变量。

        NSString *propertyVariable = nil;
        if (!variable || !*variable) {
            propertyVariable = [NSString stringWithFormat:@"_%@", propertyName];
        } else {
            propertyVariable = [NSString stringWithCString:variable
                                                  encoding:NSASCIIStringEncoding];
        }
        [variables setObject:propertyVariable forKey:propertyVariable];

        free(attributes);
        attributes = NULL;
    }

    free(properties);
    properties = NULL;

    // 将类的个别方法作为属性。

    NSString *propertyName;
    NSString *propertyType;

    // NSObject

    if ([NSObject class] == class) {
        propertyName = @"retainCount";
        propertyType = [NSString stringWithCString:@encode(NSUInteger)
                                          encoding:NSASCIIStringEncoding];
        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyName}];

        propertyName = @"version";
        propertyType = [NSString stringWithCString:@encode(NSUInteger)
                                          encoding:NSASCIIStringEncoding];
        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyName}];
    }

    // UIViewController

    else if (NSClassFromString(@"UIViewController") == class) {
        propertyName = @"isViewLoaded";
        propertyType = [NSString stringWithCString:@encode(BOOL)
                                          encoding:NSASCIIStringEncoding];
        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyName}];
    }

    // UIView

    else if (NSClassFromString(@"UIView") == class) {
        propertyName = @"superview";
        propertyType = [NSString stringWithCString:@encode(id)
                                          encoding:NSASCIIStringEncoding];
        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyName}];

        propertyName = @"subviews";
        propertyType = [NSString stringWithCString:@encode(NSArray *)
                                          encoding:NSASCIIStringEncoding];
        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyName}];

        propertyName = @"constraints";
        propertyType = [NSString stringWithCString:@encode(NSArray *)
                                          encoding:NSASCIIStringEncoding];
        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyGetter: propertyName}];
    }

    // 遍历实例变量列表，将各实例变量信息保存到字典，并放入返回数组。

    unsigned int ivarCount = 0;
    Ivar *ivars = NULL;
    ivars = class_copyIvarList(class, &ivarCount);

    for (int i = 0; i < ivarCount; ++i) {

        // 取出当前实例变量的关键信息。

        NSString *propertyName = [NSString stringWithCString:ivar_getName(ivars[i])
                                                    encoding:NSASCIIStringEncoding];
        NSString *propertyType = [NSString stringWithCString:ivar_getTypeEncoding(ivars[i])
                                                    encoding:NSASCIIStringEncoding];
        NSNumber *propertyOffset = @((NSUInteger)ivar_getOffset(ivars[i]));

        // 如果当前实例变量与属性绑定的，则跳过。

        if ([variables objectForKey:propertyName]) {
            continue;
        }

        // 将实例变量的相关信息保存到返回数组里面。

        [array addObject:@{CSPropertyName: propertyName,
                           CSPropertyHost: propertyHost,
                           CSPropertyType: propertyType,
                           CSPropertyOffset: propertyOffset}];
    }

    free(ivars);
    ivars = NULL;

    return array;
}


@implementation NSObject (Dump)

// 转储对象的关键信息。
- (NSString *)dump
{
    ODDumpOptions options = 0;

    options |= ODDumpSelf;
    options |= ODDumpSuper;
    options |= ODDumpSortMembers;
    options |= ODDumpFirstOnly;
    options |= ODDumpTypeClear;

    return [self dumpWithOptions:options
                        maxDepth:256
                       maxLength:4 * 1024 * 1024];
}

// 转储对象的关键信息，但限制转储的最大层数。
- (NSString *)dump:(NSUInteger)maxDepth
{
    ODDumpOptions options = 0;

    options |= ODDumpSelf;
    options |= ODDumpSuper;
    options |= ODDumpSortMembers;
    options |= ODDumpFirstOnly;

    return [self dumpWithOptions:options
                        maxDepth:maxDepth
                       maxLength:4 * 1024 * 1024];
}

// 转储对象的详细信息。
- (NSString *)dumpDetail
{
    ODDumpOptions options = 0;

    options |= ODDumpSelf;
    options |= ODDumpSuper;
    options |= ODDumpSystem;
    options |= ODDumpSortMembers;
    options |= ODDumpFirstOnly;

    return [self dumpWithOptions:options
                        maxDepth:1
                       maxLength:4 * 1024 * 1024];
}

// 转储对象的所有信息。
- (NSString *)dumpAll
{
    ODDumpOptions options = 0;

    options |= ODDumpSelf;
    options |= ODDumpSuper;
    options |= ODDumpSystem;
    options |= ODDumpSortMembers;
    options |= ODDumpFirstOnly;

    return [self dumpWithOptions:options
                        maxDepth:256
                       maxLength:4 * 1024 * 1024];
}

// 转储对象信息。
- (NSString *)dumpWithOptions:(ODDumpOptions)options
                     maxDepth:(NSUInteger)maxDepth
                    maxLength:(NSUInteger)maxLength
{
    return [self dumpWithOptions:options
                    indentLength:0
                     objectStack:[NSMutableArray arrayWithCapacity:0]
                    currentDepth:1
                        maxDepth:maxDepth
                   currentLength:0
                       maxLength:maxLength];
}

// 转储对象信息。
- (NSString *)dumpWithOptions:(ODDumpOptions)options
                 indentLength:(NSUInteger)indentLength
                  objectStack:(NSMutableArray *)objectStack
                 currentDepth:(NSUInteger)currentDepth
                     maxDepth:(NSUInteger)maxDepth
                currentLength:(NSUInteger)currentLength
                    maxLength:(NSUInteger)maxLength
{
    NSString *class = NSStringFromClass([self class]);
    NSString *name = [NSString stringWithFormat:@"<%@: %p>", class, self];

    // 转储原子类对象（不需要关注其内部属性，直接显示其值）。

    NSString *dump = [self dumpAtomObject];
    if (dump) {
        if (currentDepth <= 1) {
            return [name stringByAppendingString:dump];
        } else {
            return dump;
        }
    }

    // 如果已经超过最大深度，则直接返回对象名称即可。

    if (currentDepth > 1 && currentDepth > maxDepth) {
        return [name stringByAppendingString:@" {...}"];
    }

    // 如果存在递归循环，则不再展开，直接返回对象名称即可。

    for (id obj in objectStack) {
        if (obj == self) {
            return [name stringByAppendingString:@" {... see above ...}"];
        }
    }

    [objectStack addObject:self];

    @try {

        // 转储集合类对象。

        if (!dump) {
            dump = [self dumpAggregationObjectWithOptions:options
                                             indentLength:indentLength
                                              objectStack:objectStack
                                             currentDepth:currentDepth
                                                 maxDepth:maxDepth
                                            currentLength:currentLength
                                                maxLength:maxLength];
        }

        // 转储一般性对象。

        if (!dump) {
            dump = [self dumpOrdinaryObjectWithOptions:options
                                          indentLength:indentLength
                                           objectStack:objectStack
                                          currentDepth:currentDepth
                                              maxDepth:maxDepth
                                         currentLength:currentLength
                                             maxLength:maxLength];
        }
    }
    @catch (NSException *exception) {
        dump = [NSString stringWithFormat:@"%@ {exception:%@}", name, exception];
    }

    // 如果显示的是"<name> {}"，则提示可以发送dumpDetail消息查看详细信息。

    if (currentDepth <= 1 && [dump length] <= [name length] + 3) {
        dump = [dump stringByAppendingString:
                @"\nTry to send message `dumpDetail' to this instance."];
    }

    // 如果支持仅转储同一个对象第一次出现的地方，则需要将对象保留在对象栈中。

    if (!(options & ODDumpFirstOnly)) {
        assert([objectStack lastObject] == self);
        [objectStack removeLastObject];
    }

    return dump;
}

// 转储原子对象信息。
- (NSString *)dumpAtomObject
{
    // 字符串

    if ([self isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@\"%@\"", self];
    }

    // 带格式字符串

    if ([self isKindOfClass:[NSAttributedString class]]) {
        return [self description];
    }

    // 值

    if ([self isKindOfClass:[NSValue class]]) {
        return [self description];
    }

    // 日期

    if ([self isKindOfClass:[NSDate class]]) {
        return [NSString stringWithFormat:@"## %@ ##", self];
    }

    // 空

    if ([self isKindOfClass:[NSNull class]]) {
        return @"(NSNull)";
    }

    // Class

    if ([self class] == self) {
        return [NSString stringWithFormat:@"(Class)%@", [self class]];
    }

    // URL

    if ([self isKindOfClass:[NSURL class]]) {
        return [self description];
    }

    // UUID

    if ([self isKindOfClass:[NSUUID class]]) {
        return [(NSUUID *)self UUIDString];
    }

    return nil;
}

// 转储集合对象信息。
- (NSString *)dumpAggregationObjectWithOptions:(ODDumpOptions)options
                                  indentLength:(NSUInteger)indentLength
                                   objectStack:(NSMutableArray *)objectStack
                                  currentDepth:(NSUInteger)currentDepth
                                      maxDepth:(NSUInteger)maxDepth
                                 currentLength:(NSUInteger)currentLength
                                     maxLength:(NSUInteger)maxLength
{
    NSMutableDictionary *members = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *allOrderedKeys = [NSMutableArray arrayWithCapacity:0];

    // 数组

    if ([self isKindOfClass:[NSArray class]]) {
        NSUInteger index = 0;
        for (id value in (NSArray *)self) {
            NSString *memberKey = [NSString stringWithFormat:@"(%lu): ",
                                   (unsigned long)index++];
            id memberValue = value;
            if ([memberValue isKindOfClass:[NSString class]]) {
                memberValue = [memberValue dumpAtomObject];
            }
            [members setObject:memberValue forKey:memberKey];
            [allOrderedKeys addObject:memberKey];
        }
    }

    // 字典

    else if ([self isKindOfClass:[NSDictionary class]]) {
        for (id key in (NSDictionary *)self) {
            NSString *memberKey;
            if ([key isKindOfClass:[NSString class]]) {
                memberKey = key;
            } else {
                memberKey = [NSString stringWithFormat:@"<%@: %p>",
                             NSStringFromClass([key class]), key];
            }
            memberKey = [NSString stringWithFormat:@"[%@]: ", memberKey];
            id memberValue = [(NSDictionary *)self objectForKey:key];
            if ([memberValue isKindOfClass:[NSString class]]) {
                memberValue = [memberValue dumpAtomObject];
            }
            [members setObject:memberValue forKey:memberKey];
            [allOrderedKeys addObject:memberKey];
        }
    }

    // 其它

    else {
        return nil;
    }

    return [self dumpWithMembers:members
                  allOrderedKeys:allOrderedKeys
                         options:options
                    indentLength:indentLength
                     objectStack:objectStack
                    currentDepth:currentDepth
                        maxDepth:maxDepth
                   currentLength:currentLength
                       maxLength:maxLength];
}

// 转储普通对象信息。
- (NSString *)dumpOrdinaryObjectWithOptions:(ODDumpOptions)options
                               indentLength:(NSUInteger)indentLength
                                objectStack:(NSMutableArray *)objectStack
                               currentDepth:(NSUInteger)currentDepth
                                   maxDepth:(NSUInteger)maxDepth
                              currentLength:(NSUInteger)currentLength
                                  maxLength:(NSUInteger)maxLength
{
    // 获取当前类的属性列表。

    NSArray *properties = ODGetClassProperties([self class]);
    if (options & ODDumpSortMembers) {
        properties = [properties sortedArrayUsingComparator:
                      ^NSComparisonResult(id obj1, id obj2) {
                          NSString *name1 = [obj1 objectForKey:CSPropertyName];
                          NSString *host1 = [obj1 objectForKey:CSPropertyHost];
                          NSNumber *offset1 = [obj1 objectForKey:CSPropertyOffset];

                          NSString *name2 = [obj2 objectForKey:CSPropertyName];
                          NSString *host2 = [obj2 objectForKey:CSPropertyHost];
                          NSNumber *offset2 = [obj2 objectForKey:CSPropertyOffset];

                          // 对于属性，按名称排序。

                          if (!offset1 && !offset2) {
                              return [name1 compare:name2];
                          }

                          // 实例变量排在属性的前面。

                          else if (!offset1 && offset2) {
                              return NSOrderedDescending;
                          }
                          else if (offset1 && !offset2) {
                              return NSOrderedAscending;
                          }

                          // 对于实例变量，先按类进行排序，然后按名称排序。

                          else if (offset1 && offset2) {
                              if ([host1 isEqualToString:host2]) {
                                  return [name1 compare:name2];
                              } else {
                                  Class class1 = NSClassFromString(host1);
                                  Class class2 = NSClassFromString(host2);

                                  // 父类实例变量排在子类实例变量前面。

                                  if ([class1 isKindOfClass:class2]) {
                                      return NSOrderedDescending;
                                  } else {
                                      return NSOrderedAscending;
                                  }
                              }
                          }

                          return NSOrderedSame;
                      }];
    }

    // 遍历属性列表，转储各个属性。

    NSMutableDictionary *members = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *allOrderedKeys = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *messages = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *class = NSStringFromClass([self class]);

    Dl_info localModule = {0};
    dladdr(&ODGetClassProperties, &localModule);

    for (NSDictionary *property in properties) {

        NSString *name = [property objectForKey:CSPropertyName];
        NSString *type = [property objectForKey:CSPropertyType];
        NSString *host = [property objectForKey:CSPropertyHost];
        NSString *getter = [property objectForKey:CSPropertyGetter];
        NSNumber *offset = [property objectForKey:CSPropertyOffset];

        // 如果不支持转储来自父类的属性，则跳过。

        if (!(options & ODDumpSuper) && ![host isEqualToString:class]) {
            continue;
        }

        // 如果之前已经对当前对象发送过相同的name:getter:offset消息，则不再处理。
        // 有些父类及子类都定义了相同的属性，就会出现这种情况。

        NSString *unique = [NSString stringWithFormat:@"%@:%@:%@",
                            name, getter, offset];
        if ([messages objectForKey:unique]) {
            continue;
        }

        // 针对结构体/枚举，将其类型字符串中用双引用号括起的变量删除掉，使与可与
        // @encode(...)返回的类型字符串进行比较。

        if (0 == [type rangeOfString:@"{"].location) {
            type = [type stringByReplacingOccurrencesOfString:@"\"[^\"]*\""
                                                   withString:@""
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, [type length])];
        }

        // 生成属性的转储信息。

        NSString *key = [NSString stringWithFormat:@"%@ = ", name];
        NSString *value = nil;
        const char *encode = [type cStringUsingEncoding:NSASCIIStringEncoding];
        SEL SEL_getter = NULL;

        if (offset) {
            key = [NSString stringWithFormat:@"%@->%@", host, key];
        } else {
            SEL_getter = NSSelectorFromString(getter);
        }

        @try {
            ODDumpPropertyBegin()
            ODDumpProtoProperty(int, @"%d")
            ODDumpProtoProperty(unsigned int, @"%u")
            ODDumpProtoProperty(char, @"%hhd")
            ODDumpProtoProperty(unsigned char, @"%hhu")
            ODDumpProtoProperty(short int, @"%hd")
            ODDumpProtoProperty(unsigned short int, @"%hu")
            ODDumpProtoProperty(long int, @"%ld")
            ODDumpProtoProperty(unsigned long int, @"%lu")
            ODDumpProtoProperty(long long int, @"%lld")
            ODDumpProtoProperty(unsigned long long int, @"%llu")
            ODDumpProtoProperty(char *, @"%s")
            ODDumpProtoProperty(const char *, @"%s")
            ODDumpProtoProperty(void *, @"(void *)<%p>")
            ODDumpProtoProperty(const void *, @"(const void *)<%p>")
            ODDumpFloatProperty(float, @"%f")
            ODDumpFloatProperty(double, @"%f")
            ODDumpFloatProperty(long double, @"%Lf")
            ODDumpValueProperty(BOOL, returnValue ? @"YES" : @"NO")
            ODDumpValueProperty(Class,
                                [@"(Class)" stringByAppendingString:
                                 returnValue ?
                                 NSStringFromClass(returnValue) :
                                 @"(null)"])
            ODDumpValueProperty(SEL,
                                [@"(SEL)" stringByAppendingString:
                                 returnValue ?
                                 NSStringFromSelector(returnValue) :
                                 @"(null)"])
            ODDumpStructProperty(NSRange, NSStringFromRange(returnValue))
            ODDumpStructProperty(CGPoint,
                                 ([NSString stringWithFormat:
                                   @"{%@, %@}",
                                   @(returnValue.x),
                                   @(returnValue.y)]))
            ODDumpStructProperty(CGVector,
                                 ([NSString stringWithFormat:
                                   @"{%@, %@}",
                                   @(returnValue.dx),
                                   @(returnValue.dy)]))
            ODDumpStructProperty(CGSize,
                                 ([NSString stringWithFormat:
                                   @"{%@, %@}",
                                   @(returnValue.width),
                                   @(returnValue.height)]))
            ODDumpStructProperty(CGRect,
                                 ([NSString stringWithFormat:
                                   @"{{%@, %@}, {%@, %@}}",
                                   @(returnValue.origin.x),
                                   @(returnValue.origin.y),
                                   @(returnValue.size.width),
                                   @(returnValue.size.height)]))
            ODDumpStructProperty(CGAffineTransform,
                                 ([NSString stringWithFormat:
                                   @"[%@ %@ %@ %@ %@ %@]",
                                   @(returnValue.a),
                                   @(returnValue.b),
                                   @(returnValue.c),
                                   @(returnValue.d),
                                   @(returnValue.tx),
                                   @(returnValue.ty)]))
#if TARGET_OS_IPHONE
            ODDumpStructProperty(UIEdgeInsets,
                                 ([NSString stringWithFormat:
                                   @"{%@, %@, %@, %@}",
                                   @(returnValue.top),
                                   @(returnValue.left),
                                   @(returnValue.right),
                                   @(returnValue.bottom)]))
            ODDumpStructProperty(UIOffset,
                                 ([NSString stringWithFormat:
                                   @"{%@, %@}",
                                   @(returnValue.horizontal),
                                   @(returnValue.vertical)]))
            ODDumpStructProperty(CATransform3D,
                                 ([NSString stringWithFormat:
                                   @"{{%@, %@, %@, %@},"
                                   @" {%@, %@, %@, %@},"
                                   @" {%@, %@, %@, %@},"
                                   @" {%@, %@, %@, %@}}",
                                   @(returnValue.m11),
                                   @(returnValue.m12),
                                   @(returnValue.m13),
                                   @(returnValue.m14),
                                   @(returnValue.m21),
                                   @(returnValue.m22),
                                   @(returnValue.m23),
                                   @(returnValue.m24),
                                   @(returnValue.m31),
                                   @(returnValue.m32),
                                   @(returnValue.m33),
                                   @(returnValue.m34),
                                   @(returnValue.m41),
                                   @(returnValue.m42),
                                   @(returnValue.m43),
                                   @(returnValue.m44)]))
#endif // TARGET_OS_IPHONE
            ODDumpObjectProperty()
            ODDumpPropertyEnd()
        }
        @catch (NSException *exception) {
            value = [NSString stringWithFormat:@"(exception:%@)", exception];
        }

        // 如果不支持转储来自系统类的属性，则跳过。
        // 但如果属性虽然是来自系统类的，但其返回值指向本地类实例，则仍进行显示。

        Dl_info hostModule = {0}, valueModule = {0};
        if (!(options & ODDumpSystem)
            && dladdr((__bridge const void *)NSClassFromString(host), &hostModule)
            && localModule.dli_fbase != hostModule.dli_fbase
            && dladdr((__bridge const void *)[value class], &valueModule)
            && localModule.dli_fbase != valueModule.dli_fbase) {
            continue;
        }

        assert(key && value);
        [members setObject:value forKey:key];
        [allOrderedKeys addObject:key];
        [messages setObject:unique forKey:unique];
    }

    return [self dumpWithMembers:members
                  allOrderedKeys:allOrderedKeys
                         options:options
                    indentLength:indentLength
                     objectStack:objectStack
                    currentDepth:currentDepth
                        maxDepth:maxDepth
                   currentLength:currentLength
                       maxLength:maxLength];
}

// 根据传入的成员列表及选项转储当前对象。
- (NSString *)dumpWithMembers:(NSDictionary *)members
               allOrderedKeys:(NSArray *)allOrderedKeys
                      options:(ODDumpOptions)options
                 indentLength:(NSUInteger)indentLength
                  objectStack:(NSMutableArray *)objectStack
                 currentDepth:(NSUInteger)currentDepth
                     maxDepth:(NSUInteger)maxDepth
                currentLength:(NSUInteger)currentLength
                    maxLength:(NSUInteger)maxLength
{
    // 定义缩进格式及生成用于缩进的字符串。

    NSString *ind = @"    "; assert(0 == indentLength % [ind length]);
    NSString *tab = @"    "; assert([ind length] == [tab length]);

    NSMutableString *indent = [NSMutableString stringWithCapacity:indentLength];
    for (NSUInteger i = indentLength / [ind length]; i > 0 ; --i) {
        [indent appendString:ind];
    }

    // 生成用到的基本的字符串，如名称、抬头、底脚、更多等。

    NSString *name = [NSString stringWithFormat:@"<%@: %p>",
                      NSStringFromClass([self class]), self];
    NSString *header = [name stringByAppendingString:@" {\n"];
    NSString *footer = [indent stringByAppendingString:@"}"];
    NSString *more = [NSString stringWithFormat:@"%@%@... More ...\n", indent, tab];

    NSUInteger leastLength = currentLength + [header length] + [footer length];
    NSUInteger realtimeLength = 0;

    // 计算列出当前类所有成员的基本信息所需长度。
    // 成员信息的格式为："<indent><tab><key><value>\n"。
    // 其中<key>的格式由调用者确定，一般为："<name> = (<type>)"。

    realtimeLength = leastLength;
    for (NSString *key in allOrderedKeys) {
        id value = [members objectForKey:key];
        realtimeLength += [indent length] + [tab length] + [key length] + 1;
        if ([value isKindOfClass:[NSString class]]) {
            realtimeLength += [value length];
        } else {
            // <<name>: <address>> {...}
            realtimeLength += [NSStringFromClass([value class]) length];
            realtimeLength += (NSUInteger)(log((uint64_t)value) / log(16) + 1);
            realtimeLength += 12;
        }
    }

    // 如果没有成员，则直接返回"{}"。

    if (realtimeLength == leastLength) {
        return [name stringByAppendingString:@" {}"];
    }

    // 如果所需长度超过最大长度，则直接返回"{...}"。
    // 但如果当前是第一层，则允许显示部份成员数据，并在最末显示"... More ..."。

    if (realtimeLength > maxLength) {
        leastLength += (currentDepth <= 1) ? [more length] : realtimeLength;
        if (leastLength > maxLength) {
            return [name stringByAppendingString:@" {...}"];
        }
    }

    // 在显示基本数据外空余的长度上dump对象成员的明细数据。

    NSUInteger spaceLength = maxLength - realtimeLength;
    spaceLength = (maxLength > realtimeLength) ? spaceLength : 0;
    NSMutableString *dump = [NSMutableString stringWithCapacity:0];
    NSMutableArray *holder = [NSMutableArray arrayWithCapacity:0];

    realtimeLength = leastLength;
    for (NSString *key in allOrderedKeys) {
        id value = [members objectForKey:key];
        realtimeLength += [indent length] + [tab length] + [key length] + 1;

        // 如果当前成员的值是字符串对象类型，则直接显示其值。

        if ([value isKindOfClass:[NSString class]]) {
            realtimeLength += [value length];
            if (realtimeLength > maxLength) {
                break;
            }
            [dump appendFormat:@"%@%@%@%@\n", indent, tab, key, value];
            continue;
        }

        // 如果仅展开类型明确的对象，则忽略id类型的对象。

        BOOL ignoreValue = NO;
        if ((options & ODDumpTypeClear)
            && NSNotFound != [key rangeOfString:@" = (id"].location) {
            ignoreValue = YES;
            for (id obj in objectStack) {
                if (obj == value) {
                    ignoreValue = NO;
                    break;
                }
            }
        }

        // 如果还有空余的长度，则dump对象成员的值。

        NSString *valueDump = nil;
        if (!ignoreValue && spaceLength > 0) {
            @autoreleasepool {
                valueDump = [value dumpWithOptions:options
                                      indentLength:[indent length] + [tab length]
                                       objectStack:objectStack
                                      currentDepth:currentDepth + 1
                                          maxDepth:maxDepth
                                     currentLength:0
                                         maxLength:spaceLength];
                if (!valueDump) {
                    valueDump = @"(null)";
                }
                [holder addObject:valueDump];
            }
        }

        // 如果超过了空余的长度，则直接显示"<<name>: <address>> {...}"。

        if (ignoreValue || spaceLength <= 0 || [valueDump length] > spaceLength) {
            valueDump = [NSString stringWithFormat:@"<%@: %p> {...}",
                         NSStringFromClass([value class]), value];
            spaceLength = ignoreValue ? spaceLength : 0;
        } else {
            spaceLength -= (spaceLength <= 0) ? 0 : [valueDump length];
        }

        // 将当前成员的dump数据合并到对象的dump数据。

        realtimeLength += [valueDump length];
        if (realtimeLength > maxLength) {
            break;
        }
        [dump appendFormat:@"%@%@%@%@\n", indent, tab, key, valueDump];
        [holder removeAllObjects];
    }

    if (realtimeLength > maxLength && currentDepth <= 1) {
        [dump appendString:more];
    }

    return [NSString stringWithFormat:@"%@%@%@", header, dump, footer];
}

@end
