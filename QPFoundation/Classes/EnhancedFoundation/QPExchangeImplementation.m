//
//  QPExchangeImplementation.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/21.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPExchangeImplementation.h>
#import <objc/runtime.h>


QP_STATIC_KEYNAME(QPExchangeImplementationException);


void QPExchangeImplementation(Class attachedClass,
                              SEL originalSelector,
                              SEL replacementSelector)
{
    Method originalMethod;
    Method replacementMethod;

    // 获取当前类在替换前后的目标方法。

    originalMethod = class_getInstanceMethod(attachedClass,
                                             originalSelector);

    replacementMethod = class_getInstanceMethod(attachedClass,
                                                replacementSelector);

    if (!originalMethod || !replacementMethod) {
        [NSException raise:QPExchangeImplementationException format:
         @"[QPFoundation] Original or replacement method is not exists."];
    }

    // 将可能是父类的方法添加到当前类的方法列表上。
    // 如果当前类已经存在该方法，则不会作作何变更。

    if (class_addMethod(attachedClass,
                        originalSelector,
                        method_getImplementation(originalMethod),
                        method_getTypeEncoding(originalMethod)))
    {
#ifdef DEBUG
        NSLog(@"[QPFoundation] Copy superclass's -%@ method to %@ class.",
              NSStringFromSelector(originalSelector),
              attachedClass);
#endif /* DEBUG */
    }

    if (class_addMethod(attachedClass,
                        replacementSelector,
                        method_getImplementation(replacementMethod),
                        method_getTypeEncoding(replacementMethod)))
    {
#ifdef DEBUG
        NSLog(@"[QPFoundation] Copy superclass's -%@ method to %@ class.",
              NSStringFromSelector(replacementSelector),
              attachedClass);
#endif /* DEBUG */
    }

    // 获取当前类在替换前后的目标方法，并将其实现函数进行互换。

    originalMethod = class_getInstanceMethod(attachedClass,
                                             originalSelector);

    replacementMethod = class_getInstanceMethod(attachedClass,
                                                replacementSelector);

    method_exchangeImplementations(originalMethod, replacementMethod);

#ifdef DEBUG
    NSLog(@"[QPFoundation] Exchange implementations with -%@ method "
          @"and -%@ method of %@ class.",
          NSStringFromSelector(originalSelector),
          NSStringFromSelector(replacementSelector),
          attachedClass);
#endif /* DEBUG */
}
