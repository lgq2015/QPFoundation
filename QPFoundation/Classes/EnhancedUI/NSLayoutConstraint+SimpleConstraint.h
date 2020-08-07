//
//  NSLayoutConstraint+SimpleConstraint.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


/**
 *  用于简化使用Visual Format Language来定义视图间约束关系的代码。
 *  使用示例如下：
 *       NSNumber *priority = @(QPLayoutPriorityFittingSize);
 *       NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
 *       NSDictionary *metrics = NSDictionaryOfVariableBindings(priority);
 *
 *       QPVisualFormatBegin(_wrapperView, metrics, views);
 *       QPVisualFormat(@"H:|-(0@priority,>=0)-[_contentView]-(0@priority)-|");
 *       QPVisualFormat(@"V:|-(0@priority,>=0)-[_contentView]-(0@priority)-|");
 *       QPVisualFormatEnd();
 */
#define QPVisualFormatBegin(container, metrics, views) \
    do { \
        UIView *__container = (container); \
        NSDictionary *__metrics = (metrics); \
        NSDictionary *__views = (views)

#define QPVisualFormat(statement_and_optional_options, ...) \
        ([__container addConstraints: \
          [NSLayoutConstraint \
           constraintsWithVisualFormat:(statement_and_optional_options) \
           options:(__VA_ARGS__ + 0) \
           metrics:__metrics \
           views:__views]])

#define QPVisualFormatEnd() \
    } while (0)


/**
 *  架框定义的用于拉伸视图大小的优先级，高于原生控件的反抗压缩内容的优先级。
 */
static const UILayoutPriority QPLayoutPriorityFittingSize = UILayoutPriorityDefaultHigh + (UILayoutPriorityRequired - UILayoutPriorityDefaultHigh) * 0.25;

/**
 *  架框定义的用于一般性用途的较低的优先级，高于原生控件的反抗压缩内容的优先级。
 */
static const UILayoutPriority QPLayoutPriorityLow = UILayoutPriorityDefaultHigh + (UILayoutPriorityRequired - UILayoutPriorityDefaultHigh) * 0.50;

/**
 *  架框定义的用于一般性用途的较高的优先级，高于原生控件的反抗压缩内容的优先级。
 */
static const UILayoutPriority QPLayoutPriorityHigh = UILayoutPriorityDefaultHigh + (UILayoutPriorityRequired - UILayoutPriorityDefaultHigh) * 0.75;

/**
 *  与UILayoutPriorityRequired相等，表示必须支持的优先级。
 */
static const UILayoutPriority QPLayoutPriorityRequired = UILayoutPriorityRequired;


@interface NSLayoutConstraint (SimpleConstraint)

/**
 *  创建由指定参数定义的约束，与系统提供的方法相比priority参数可以在创建时指定。
 */
+ (instancetype)constraintWithItem:(id)view1
                         attribute:(NSLayoutAttribute)attr1
                         relatedBy:(NSLayoutRelation)relation
                            toItem:(id)view2
                         attribute:(NSLayoutAttribute)attr2
                        multiplier:(CGFloat)multiplier
                          constant:(CGFloat)constant
                          priority:(UILayoutPriority)priority;

@end
