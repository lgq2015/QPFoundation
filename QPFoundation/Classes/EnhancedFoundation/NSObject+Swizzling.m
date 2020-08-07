//
//  NSObject+Swizzling.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/1/13.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSObject+Swizzling.h>
#import <QPFoundation/QPExchangeImplementation.h>

@implementation NSObject (Swizzling)

+ (void)swizzleSelector:(SEL)originalSelector
             toSelector:(SEL)replacementSelector
{
    QPExchangeImplementation([self class],
                             originalSelector,
                             replacementSelector);
}

@end
