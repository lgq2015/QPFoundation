//
//  QPPublicHeader.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <Foundation/Foundation.h>

#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR)

#import <UIKit/UIKit.h>

#endif /* (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) */


/**
 *  定义字符串常量。
 */
#define QP_EXPORT_STRING(c)                 FOUNDATION_EXPORT NSString *const c
#define QP_DEFINE_STRING(c, v)              NSString *const c = (@"" v)
#define QP_STATIC_STRING(c, v)              static QP_DEFINE_STRING(c, v)


/**
 *  定义整型数常量。
 */
#define QP_EXPORT_INTEGER(c)                FOUNDATION_EXPORT const NSInteger c
#define QP_DEFINE_INTEGER(c, v)             const NSInteger c = (v)
#define QP_STATIC_INTEGER(c, v)             static QP_DEFINE_INTEGER(c, v)


/**
 *  定义浮点数常量。
 */
#define QP_EXPORT_FLOAT(c)                  FOUNDATION_EXPORT const CGFloat c
#define QP_DEFINE_FLOAT(c, v)               const CGFloat c = (v)
#define QP_STATIC_FLOAT(c, v)               static QP_DEFINE_FLOAT(c, v)


/**
 *  定义布尔值常量。
 */
#define QP_EXPORT_BOOLEAN(c)                FOUNDATION_EXPORT const BOOL c
#define QP_DEFINE_BOOLEAN(c, v)             const BOOL c = (v)
#define QP_STATIC_BOOLEAN(c, v)             static QP_DEFINE_BOOLEAN(c, v)


/**
 *  定义数组常量。
 */
#define QP_EXPORT_ARRAY(c)                  FOUNDATION_EXPORT NSArray *const c
#ifdef __cplusplus
#define QP_DEFINE_ARRAY(c, v)               NSArray *const c = (v)
#define QP_STATIC_ARRAY(c, v)               static QP_DEFINE_ARRAY(c, v)
#endif


/**
 *  定义字典常量。
 */
#define QP_EXPORT_DICTIONARY(c)             FOUNDATION_EXPORT NSDictionary *const c
#ifdef __cplusplus
#define QP_DEFINE_DICTIONARY(c, v)          NSDictionary *const c = (v)
#define QP_STATIC_DICTIONARY(c, v)          static QP_DEFINE_DICTIONARY(c, v)
#endif


/**
 *  定义时间间隔常量。
 */
#define QP_EXPORT_TIMEINTERVAL(c)           FOUNDATION_EXPORT const NSTimeInterval c
#define QP_DEFINE_TIMEINTERVAL(c, v)        const NSTimeInterval c = (v)
#define QP_STATIC_TIMEINTERVAL(c, v)        static QP_DEFINE_TIMEINTERVAL(c, v)


/**
 *  定义颜色常量。
 */
#define QP_EXPORT_COLOR(c)                  FOUNDATION_EXPORT const NSUInteger c
#define QP_DEFINE_COLOR(c, v)               const NSUInteger c = (v)
#define QP_STATIC_COLOR(c, v)               static QP_DEFINE_COLOR(c, v)


/**
 *  定义字体大小常量。
 */
#define QP_EXPORT_FONTSIZE(c)               FOUNDATION_EXPORT const CGFloat c
#define QP_DEFINE_FONTSIZE(c, v)            const CGFloat c = (v)
#define QP_STATIC_FONTSIZE(c, v)            static QP_DEFINE_FONTSIZE(c, v)


/**
 *  定义范围常量。
 */
#define QP_EXPORT_RANGE(c)                  FOUNDATION_EXPORT const NSRange c
#define QP_DEFINE_RANGE(c, loc, len)        const NSRange c = {(loc), (len)}
#define QP_STATIC_RANGE(c, loc, len)        static QP_DEFINE_RANGE(c, loc, len)


/**
 *  定义区域常量。
 */
#define QP_EXPORT_RECT(c)                   FOUNDATION_EXPORT const CGRect c
#define QP_DEFINE_RECT(c, x, y, w, h)       const CGRect c = {(x), (y), (w), (h)}
#define QP_STATIC_RECT(c, x, y, w, h)       static QP_DEFINE_RECT(c, x, y, w, h)


/**
 *  定义位置常量。
 */
#define QP_EXPORT_POINT(c)                  FOUNDATION_EXPORT const CGPoint c
#define QP_DEFINE_POINT(c, x, y)            const CGPoint c = {(x), (y)}
#define QP_STATIC_POINT(c, x, y)            static QP_DEFINE_POINT(c, x, y)


/**
 *  定义大小常量。
 */
#define QP_EXPORT_SIZE(c)                   FOUNDATION_EXPORT const CGSize c
#define QP_DEFINE_SIZE(c, w, h)             const CGSize c = {(w), (h)}
#define QP_STATIC_SIZE(c, w, h)             static QP_DEFINE_SIZE(c, w, h)


/**
 *  定义向量常量。
 */
#define QP_EXPORT_VECTOR(c)                 FOUNDATION_EXPORT const CGVector c
#define QP_DEFINE_VECTOR(c, dx, dy)         const CGVector c = {(dx), (dy)}
#define QP_STATIC_VECTOR(c, dx, dy)         static QP_DEFINE_VECTOR(c, dx, dy)


/**
 *  定义四周边距常量。
 */
#define QP_EXPORT_EDGEINSETS(c)             FOUNDATION_EXPORT const UIEdgeInsets c
#define QP_DEFINE_EDGEINSETS(c, t, l, b, r) const UIEdgeInsets c = {(t), (l), (b), (r)}
#define QP_STATIC_EDGEINSETS(c, t, l, b, r) static QP_DEFINE_EDGEINSETS(c, t, l, b, r)


/**
 *  定义偏移常量。
 */
#define QP_EXPORT_OFFSET(c)                 FOUNDATION_EXPORT const UIOffset c
#define QP_DEFINE_OFFSET(c, h, v)           const UIOffset c = {(h), (v)}
#define QP_STATIC_OFFSET(c, h, v)           static QP_DEFINE_OFFSET(c, h, v)


/**
 *  定义变换矩阵常量。
 */
#define QP_EXPORT_AFFINETRANSFORM(v) \
    FOUNDATION_EXPORT const CGAffineTransform v

#define QP_DEFINE_AFFINETRANSFORM(v, a, b, c, d, tx, ty) \
    const CGAffineTransform v = {(a), (b), (c), (d), (tx), (ty)}

#define QP_STATIC_AFFINETRANSFORM(v, a, b, c, d, tx, ty) \
    static QP_DEFINE_AFFINETRANSFORM(v, a, b, c, d, tx, ty)


/**
 *  定义作为键名、通知名等的字符串常量。
 */
#define QP_EXPORT_KEYNAME(key)              FOUNDATION_EXPORT NSString *const key
#define QP_DEFINE_KEYNAME(key)              NSString *const key = (@"" #key)
#define QP_STATIC_KEYNAME(key)              static QP_DEFINE_KEYNAME(key)


/**
 *  定义作为全局唯一指针位置的指针常量，常用作KVO中的context、关联对象的key等。
 */
#define QP_EXPORT_UNIPOINTER(unipointer)    FOUNDATION_EXPORT void *const unipointer
#define QP_DEFINE_UNIPOINTER(unipointer)    void *const unipointer = (void *const)&(unipointer)
#define QP_STATIC_UNIPOINTER(unipointer)    static QP_DEFINE_UNIPOINTER(unipointer)


/**
 *  将字面量转换为字符串。
 */
#define QPLiteralness(...)          (@"" # __VA_ARGS__)


/**
 *  如果a有非空值(!= nil && != empty)则返回a，否则返回b。
 */
#define QPNvl(a, b)                 ({ __typeof__(a) __a = (a); __a ? __a : (b); })
#define QPNvlString(a, b)           ({ NSString *__a = (a); ([__a length] > 0) ? __a : (b); })
#define QPNvlArray(a, b)            ({ NSArray *__a = (a); ([__a count] > 0) ? __a : (b); })
#define QPNvlDictionary(a, b)       ({ NSDictionary *__a = (a); ([__a count] > 0) ? __a : (b); })


/**
 *  如果a有非空值(!= nil && != empty)则返回a，否则返回空值(== empty)。
 */
#define QPNonnullString(a)          QPNvlString(a, @"")
#define QPNonnullArray(a)           QPNvlArray(a, (@[]))
#define QPNonnullDictionary(a)      QPNvlDictionary(a, (@{}))


/**
 *  交换两个变量的值。
 */
#define QPSwap(a, b)                ({ __typeof__(a) __a = (a); (a) = (b); (b) = __a; 1; })


/**
 *  释放变量指向对象的所有权，使其可以在block中安全地使用，而不会产生引用循环的
 *  问题。由于需要重新定义变量，建议配合QPCodeSnippet函数使用，使得只在代码片的
 *  作用范内释放变量指向对象的所有权，当代码片执行完后又再恢复其所有权。
 */
#if __has_feature(objc_arc)

#define QPReleaseOwnership(variable) \
    __unsafe_unretained __typeof__(variable) __release_ownership_##variable = (variable); \
    __weak __typeof__(variable) variable = (__release_ownership_##variable);

#else /* __has_feature(objc_arc) */

#define QPReleaseOwnership(variable) \
    __unsafe_unretained __typeof__(variable) __release_ownership_##variable = (variable); \
    __unsafe_unretained __typeof__(variable) variable = (__release_ownership_##variable);

#endif /* !__has_feature(objc_arc) */


/**
 *  定义代码片并立即执行，仅用于方便地将一段代码括起来。
 */
NS_INLINE
void
QPCodeSnippet(void (^code)(void)) {
    code();
}


/**
 *  在主线程上执行代码片。
 */
NS_INLINE
void
QPPerformBlockOnMainThread(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


/**
 *  在主线程上执行代码片。
 */
NS_INLINE
void
QPPerformBlockOnMainThreadAndWait(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
