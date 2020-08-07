//
//  QPScrollPanelController.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/7.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPScrollPanelController.h>
#import <QPFoundation/NSLayoutConstraint+SimpleConstraint.h>


@interface QPScrollPanelWrapperView : UIScrollView
@end
@implementation QPScrollPanelWrapperView
@end


@implementation QPScrollPanelController

- (UIScrollView *)scrollView
{
    return (UIScrollView *)self.wrapperView;
}

- (void)loadWrapperView
{
    UIView *wrapperView = [[QPScrollPanelWrapperView alloc] init];
    UIView *contentView = self.contentView;
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [wrapperView setClipsToBounds:NO];
    [wrapperView addSubview:contentView];

    NSNumber *priority = @(QPLayoutPriorityFittingSize);
    NSDictionary *views = NSDictionaryOfVariableBindings(wrapperView,
                                                         contentView);
    NSDictionary *metrics = NSDictionaryOfVariableBindings(priority);

    QPVisualFormatBegin(wrapperView, metrics, views);
    QPVisualFormat(@"H:|[contentView(==wrapperView@priority)]");
    QPVisualFormat(@"V:|[contentView(>=wrapperView@priority)]");
    QPVisualFormatEnd();

    self.wrapperView = wrapperView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize oldContentSize = [self.scrollView contentSize];
        CGSize newContentSize = [self.contentView frame].size;
        if (!CGSizeEqualToSize(oldContentSize, newContentSize)) {

            // 回调变更前的响应方法。

            if ([self respondsToSelector:
                 @selector(wrapperScrollView:willChangeContentSizeFrom:to:)]) {
                [self wrapperScrollView:self.scrollView
              willChangeContentSizeFrom:oldContentSize
                                     to:newContentSize];
            }

            // 变更scrollView的contentSize。

            [self.scrollView setContentSize:newContentSize];

            // 回调变更后的响应方法。

            if ([self respondsToSelector:
                 @selector(wrapperScrollView:didChangeContentSizeFrom:to:)]) {
                [self wrapperScrollView:self.scrollView
               didChangeContentSizeFrom:oldContentSize
                                     to:newContentSize];
            }
        }
    });
}

@end
