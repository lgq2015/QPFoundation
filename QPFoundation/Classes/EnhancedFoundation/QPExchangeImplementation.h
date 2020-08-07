//
//  QPExchangeImplementation.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/21.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  交换指定类的两个实例方法的实现函数。替换的方法可以通过自己的方法名来调用原始
 *  方法的实现函数。这个函数仅在编写特定功能并且没有其它替代方案时才建议使用。
 */
FOUNDATION_EXPORT void QPExchangeImplementation(Class attachedClass,
                                                SEL originalSelector,
                                                SEL replacementSelector);
