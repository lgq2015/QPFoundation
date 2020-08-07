//
//  NSLayoutConstraint+SimpleConstraint.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSLayoutConstraint+SimpleConstraint.h>

@implementation NSLayoutConstraint (SimpleConstraint)

+ (instancetype)constraintWithItem:(id)view1
                         attribute:(NSLayoutAttribute)attr1
                         relatedBy:(NSLayoutRelation)relation
                            toItem:(id)view2
                         attribute:(NSLayoutAttribute)attr2
                        multiplier:(CGFloat)multiplier
                          constant:(CGFloat)constant
                          priority:(UILayoutPriority)priority
{
    NSLayoutConstraint *constraint;
    constraint = [NSLayoutConstraint constraintWithItem:view1
                                              attribute:attr1
                                              relatedBy:relation
                                                 toItem:view2
                                              attribute:attr2
                                             multiplier:multiplier
                                               constant:constant];
    constraint.priority = priority;
    return constraint;
}

@end
