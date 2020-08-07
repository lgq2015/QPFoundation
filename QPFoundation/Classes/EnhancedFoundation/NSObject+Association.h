//
//  NSObject+Association.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/3.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  关联对象的引用策略。
 */
typedef NS_ENUM(NSUInteger, QPAssociationPolicy) {
    QPAssociationPolicyAssign = 0,      // 无关联引用。
    QPAssociationPolicyStrong,          // 强关联引用。
    QPAssociationPolicyWeak,            // 弱关联引用。
    QPAssociationPolicyCopy             // 拷贝引用。
};


@interface NSObject (Association)

/**
 *  添加匿名关联对象。强关联引用，除非手动移除，否则一直持有直至持有者生命终结。
 */
- (void)addAssociatedObject:(id)anObject;

/**
 *  移除匿名关联对象的一个关联关系（同一对象可以关联多次）。
 */
- (void)removeAssociatedObject:(id)anObject;

/**
 *  移除匿名关联对象的所有关联关系（同一对象可以关联多次）。
 */
- (void)removeAssociatedObjectAtAll:(id)anObject;

/**
 *  判断指定对象是否是本对象的匿名关联对象。
 */
- (BOOL)isAssociatedObject:(id)anObject;

/**
 *  设置命名关联对象。强关联引用，除非手动移除，否则一直持有直至持有者生命终结。
 */
- (void)setAssociatedValue:(id)value forKey:(NSString *)key;

/**
 *  设置命名关联对象。可以通过associationPolicy参数指定引用的策略，如弱引用等。
 */
- (void)setAssociatedValue:(id)value
                    forKey:(NSString *)key
     withAssociationPolicy:(QPAssociationPolicy)associationPolicy;

/**
 *  根据名称获取命名关联对象。
 */
- (id)associatedValueForKey:(NSString *)key;

/**
 *  对象所关联的所有对象的描述信息。
 */
- (NSString *)associatedDescription;

@end
