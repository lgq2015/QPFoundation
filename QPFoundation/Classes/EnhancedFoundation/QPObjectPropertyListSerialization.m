//
//  QPObjectPropertyListSerialization.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/7/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPObjectPropertyListSerialization.h>

@implementation QPObjectPropertyListSerialization

+ (id)objectWithContentsOfFoundationObjects:(id)foundationObjects
                                    options:(NSPropertyListMutabilityOptions)options
{
    Class appearanceClass = [foundationObjects class];
    id objectInstance = nil;

    // 生成传入外表对象对应的实际对象。

    if ([appearanceClass isSubclassOfClass:[NSDictionary class]]) {
        NSString *objectClassName = [(NSDictionary *)foundationObjects
                                     objectForKey:
                                     NSStringFromSelector(@selector(class))];
        Class objectClass = NSClassFromString(QPNonnullString(objectClassName));
        if (objectClass) {
            objectInstance = [[objectClass alloc] init];
        }
        else {
            objectInstance = [[NSMutableDictionary alloc] init];
        }
    }
    else if ([appearanceClass isSubclassOfClass:[NSArray class]]) {
        objectInstance = [[NSMutableArray alloc] init];
    }
    else {
        objectInstance = foundationObjects;
    }

    // 如果外表对象是容器对象，则遍历其成员并添加到实际对象上。

    if ([appearanceClass isSubclassOfClass:[NSDictionary class]]) {
        for (id key in foundationObjects) {
            if ([key isEqual:NSStringFromSelector(@selector(class))]) {
                continue;
            }
            id memberFoundationObjects = [(NSDictionary *)foundationObjects objectForKey:key];
            id memberObjectInstance = [self objectWithContentsOfFoundationObjects:memberFoundationObjects options:options];
            if (![memberObjectInstance isKindOfClass:[NSString class]] || [memberObjectInstance length] > 0) {
                [objectInstance setValue:memberObjectInstance forKey:key];
            }
        }
    }
    else if ([appearanceClass isSubclassOfClass:[NSArray class]]) {
        for (id memberFoundationObjects in foundationObjects) {
            id memberObjectInstance = [self objectWithContentsOfFoundationObjects:memberFoundationObjects options:options];
            [(NSMutableArray *)objectInstance addObject:memberObjectInstance];
        }
    }

    // 根据传入的可变对象选项，对当前生成的实际对象进行转换。

    switch (options) {
        case NSPropertyListImmutable:
            if ([objectInstance conformsToProtocol:@protocol(NSCopying)] &&
                [objectInstance respondsToSelector:@selector(copy)]) {
                objectInstance = [objectInstance copy];
            }
            break;

        case NSPropertyListMutableContainers:
            if ([objectInstance conformsToProtocol:@protocol(NSCopying)] &&
                [objectInstance respondsToSelector:@selector(copy)] &&
                ![objectInstance isKindOfClass:[NSMutableDictionary class]] &&
                ![objectInstance isKindOfClass:[NSMutableArray class]]) {
                objectInstance = [objectInstance copy];
            }
            break;

        case NSPropertyListMutableContainersAndLeaves:
            if ([objectInstance conformsToProtocol:@protocol(NSMutableCopying)] &&
                [objectInstance respondsToSelector:@selector(mutableCopy)]) {
                objectInstance = [objectInstance mutableCopy];
            }
            break;

        default:
            break;
    }

    return objectInstance;
}

+ (id)objectWithContentsOfPropertyListData:(NSData *)data
                                   options:(NSPropertyListReadOptions)options
{
    id foundationObjects = [NSPropertyListSerialization
                            propertyListWithData:data
                            options:options
                            format:NULL
                            error:NULL];
    return [self objectWithContentsOfFoundationObjects:foundationObjects
                                               options:options];
}

+ (id)objectWithContentsOfPropertyListStream:(NSInputStream *)stream
                                     options:(NSPropertyListReadOptions)options
{
    id foundationObjects = [NSPropertyListSerialization
                            propertyListWithStream:stream
                            options:options
                            format:NULL
                            error:NULL];
    return [self objectWithContentsOfFoundationObjects:foundationObjects
                                               options:options];
}

+ (id)objectWithContentsOfPropertyListNamed:(NSString *)propertyListName
                                    options:(NSPropertyListReadOptions)options
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *propertyListPath = [mainBundle pathForResource:propertyListName
                                                      ofType:@"plist"];
    NSData *propertyListData = [NSData dataWithContentsOfFile:propertyListPath];
    return [self objectWithContentsOfPropertyListData:propertyListData
                                              options:options];
}

@end
