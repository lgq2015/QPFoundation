//
//  NSObject+Association.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/3.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSObject+Association.h>
#import <objc/runtime.h>


/**
 *  关联类别字典，是持有者唯一直接关联的对象。
 */
static char QPAssociatedCategories;

/**
 *  匿名关联对象数组的键名。
 */
QP_STATIC_KEYNAME(QPAssociatedObjects);

/**
 *  命名关联键值对字典的键名。
 */
QP_STATIC_KEYNAME(QPAssociatedKeyValuePairs);

/**
 *  命名关联带引用策略键值对字典的键名。
 */
QP_STATIC_KEYNAME(QPAssociatedPolicyKeyValuePairs);


/**
 *  获取带引用策略键值对的值的block声明。
 */
typedef id (^QPGetValueOfAssociatedPolicyKeyValuePairs)(void);


@implementation NSObject (Association)

#pragma mark - 关联类别。

- (NSMutableDictionary *)associatedCategoriesWithCreateIfNotExists:(BOOL)createIfNotExists
{
    NSMutableDictionary *associatedCategories = nil;

    @synchronized(self) {
        associatedCategories = (NSMutableDictionary *)
        objc_getAssociatedObject(self, &QPAssociatedCategories);

        if (!associatedCategories && createIfNotExists) {
            associatedCategories = [NSMutableDictionary dictionary];
            objc_setAssociatedObject(self,
                                     &QPAssociatedCategories,
                                     associatedCategories,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }

    return associatedCategories;
}

- (NSMutableArray *)associatedObjectsWithCreateIfNotExists:(BOOL)createIfNotExists
{
    NSMutableDictionary *associatedCategories = [self associatedCategoriesWithCreateIfNotExists:createIfNotExists];
    NSMutableArray *associatedObjects = nil;

    @synchronized(self) {
        associatedObjects = [associatedCategories
                             objectForKey:QPAssociatedObjects];

        if (!associatedObjects && createIfNotExists) {
            associatedObjects = [NSMutableArray array];
            [associatedCategories setValue:associatedObjects
                                    forKey:QPAssociatedObjects];
        }
    }

    return associatedObjects;
}

- (NSMutableDictionary *)associatedKeyValuePairsWithCreateIfNotExists:(BOOL)createIfNotExists
{
    NSMutableDictionary *associatedCategories = [self associatedCategoriesWithCreateIfNotExists:createIfNotExists];
    NSMutableDictionary *associatedKeyValuePairs = nil;

    @synchronized(self) {
        associatedKeyValuePairs = [associatedCategories
                                   objectForKey:QPAssociatedKeyValuePairs];

        if (!associatedKeyValuePairs && createIfNotExists) {
            associatedKeyValuePairs = [NSMutableDictionary dictionary];
            [associatedCategories setValue:associatedKeyValuePairs
                                    forKey:QPAssociatedKeyValuePairs];
        }
    }

    return associatedKeyValuePairs;
}

- (NSMutableDictionary *)associatedPolicyKeyValuePairsWithCreateIfNotExists:(BOOL)createIfNotExists
{
    NSMutableDictionary *associatedCategories = [self associatedCategoriesWithCreateIfNotExists:createIfNotExists];
    NSMutableDictionary *associatedPolicyKeyValuePairs = nil;

    @synchronized(self) {
        associatedPolicyKeyValuePairs = [associatedCategories
                                         objectForKey:QPAssociatedPolicyKeyValuePairs];

        if (!associatedPolicyKeyValuePairs && createIfNotExists) {
            associatedPolicyKeyValuePairs = [NSMutableDictionary dictionary];
            [associatedCategories setValue:associatedPolicyKeyValuePairs
                                    forKey:QPAssociatedPolicyKeyValuePairs];
        }
    }

    return associatedPolicyKeyValuePairs;
}

#pragma mark - 关联匿名对象。

- (void)addAssociatedObject:(id)anObject
{
    [[self associatedObjectsWithCreateIfNotExists:YES] addObject:anObject];
}

- (void)removeAssociatedObject:(id)anObject
{
    NSMutableArray *associatedObjects = [self associatedObjectsWithCreateIfNotExists:NO];
    NSUInteger index = [associatedObjects indexOfObjectIdenticalTo:anObject];
    if (index != NSNotFound) {
        [associatedObjects removeObjectAtIndex:index];
    }
}

- (void)removeAssociatedObjectAtAll:(id)anObject
{
    [[self associatedObjectsWithCreateIfNotExists:NO] removeObjectIdenticalTo:anObject];
}

- (BOOL)isAssociatedObject:(id)anObject
{
    NSArray *associatedObjects = [self associatedObjectsWithCreateIfNotExists:NO];
    return (associatedObjects && NSNotFound != [associatedObjects
                                                indexOfObjectIdenticalTo:anObject]);
}

#pragma mark - 关联命名对象。

- (void)setAssociatedValue:(id)value forKey:(NSString *)key
{
    [self setAssociatedValue:value
                      forKey:key
       withAssociationPolicy:QPAssociationPolicyStrong];
}

- (void)setAssociatedValue:(id)value
                    forKey:(NSString *)key
     withAssociationPolicy:(QPAssociationPolicy)associationPolicy
{
    NSMutableDictionary *associatedKeyValuePairs = [self associatedKeyValuePairsWithCreateIfNotExists:!!value];
    NSMutableDictionary *associatedPolicyKeyValuePairs = [self associatedPolicyKeyValuePairsWithCreateIfNotExists:!!value];

    // 如果传入的值为空值，则直接清空字典组中对应的键。

    if (!value) {
        [associatedKeyValuePairs setValue:nil forKey:key];
        [associatedPolicyKeyValuePairs setValue:nil forKey:key];
    }

    // 无关联引用。

    else if (QPAssociationPolicyAssign == associationPolicy) {
        __unsafe_unretained id anObject = value;
        QPGetValueOfAssociatedPolicyKeyValuePairs getter = ^id{
            return anObject;
        };
        [associatedKeyValuePairs setValue:nil forKey:key];
        [associatedPolicyKeyValuePairs setValue:getter forKey:key];
    }

    // 强关联引用。

    else if (QPAssociationPolicyStrong == associationPolicy) {
        [associatedKeyValuePairs setValue:value forKey:key];
        [associatedPolicyKeyValuePairs setValue:nil forKey:key];
    }

    // 弱关联引用。

    else if (QPAssociationPolicyWeak == associationPolicy) {
        __weak id anObject = value;
        QPGetValueOfAssociatedPolicyKeyValuePairs getter = ^id{
            return anObject;
        };
        [associatedKeyValuePairs setValue:nil forKey:key];
        [associatedPolicyKeyValuePairs setValue:getter forKey:key];
    }

    // 拷贝引用。

    else if (QPAssociationPolicyCopy == associationPolicy) {
        id anObject = [value copy];
        [associatedKeyValuePairs setValue:anObject forKey:key];
        [associatedPolicyKeyValuePairs setValue:nil forKey:key];
    }

    // 不支持的引用策略。

    else {
        NSLog(@"[QPFoundation] warning: Unsupported association policy (%d).",
              (int)associationPolicy);
        [associatedKeyValuePairs setValue:value forKey:key];
        [associatedPolicyKeyValuePairs setValue:nil forKey:key];
    }
}

- (id)associatedValueForKey:(NSString *)key
{
    NSMutableDictionary *associatedKeyValuePairs = [self associatedKeyValuePairsWithCreateIfNotExists:NO];
    NSMutableDictionary *associatedPolicyKeyValuePairs = [self associatedPolicyKeyValuePairsWithCreateIfNotExists:NO];
    id value = [associatedKeyValuePairs valueForKey:key];

    if (!value) {
        value = [associatedPolicyKeyValuePairs valueForKey:key];
        if (value) {
            value = ((QPGetValueOfAssociatedPolicyKeyValuePairs)value)();
        }
    }

    return value;
}

#pragma mark - 调试信息。

- (NSString *)associatedDescription
{
    return [[self associatedCategoriesWithCreateIfNotExists:NO] description];
}

@end
