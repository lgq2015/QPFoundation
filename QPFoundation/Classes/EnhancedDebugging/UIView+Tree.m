//
//  UIView+Tree.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/15.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIView+Tree.h>
#import <QPFoundation/QPApplicationFramework.h>


NSString *wintree()
{
    return [QPGetKeyWindow() tree];
}


@implementation UIView (Tree)

- (NSString *)tree
{
    void *wintree_holder = &wintree;
    wintree_holder = wintree_holder;

    NSString *tree = nil;
    SEL selector = NSSelectorFromString(@"recursiveDescription");
    IMP implementation = [self methodForSelector:selector];

    if (implementation) {
        NSString *(*NSRecursiveDescription)(id, SEL) = (void *)implementation;
        tree = NSRecursiveDescription(self, selector);
    }
    else {
        tree = [NSString stringWithFormat:@"%@ {...}", self];
    }

    return tree;
}

@end
