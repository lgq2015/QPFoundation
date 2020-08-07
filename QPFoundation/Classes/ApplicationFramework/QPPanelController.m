//
//  QPPanelController.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPanelController.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/NSLayoutConstraint+SimpleConstraint.h>
#import <QPFoundation/UIColor+Conversion.h>


#pragma mark - 标识化视图。

@interface QPPanelWrapperView : UIView
@end
@implementation QPPanelWrapperView
@end

@interface QPPanelWorkingView : UIView
@end
@implementation QPPanelWorkingView
@end

@interface QPPanelSelfView : UIView
@end
@implementation QPPanelSelfView
@end


@implementation QPPanelController

#pragma mark - 初始化及销毁。

QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithCoder
QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithNibName_bundle

- (void)dealloc
{
    [self removeObserver:self
              forKeyPath:@"view"];
}

- (void)initializeObject
{
    [self addObserver:self
           forKeyPath:@"view"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeView];
}

#pragma mark - 定制视图层次。

- (void)customizeView
{
    if ([self respondsToSelector:@selector(willCustomizeView)]) {
        [self willCustomizeView];
    }

    NSAssert(nil == _contentView,
             @"调用loadContentView方法前，contentView属性已经被置为有效值。");
    [self loadContentView];
    NSAssert(nil != _contentView,
             @"重写loadContentView方法时，contentView属性应该设置为有效值。");

    NSAssert(nil == _wrapperView,
             @"调用loadWrapperView方法前，wrapperView属性已经被置为有效值。");
    [self loadWrapperView];
    NSAssert(nil != _wrapperView,
             @"重写loadWrapperView方法时，wrapperView属性应该设置为有效值。");

    NSAssert(nil == _workingView,
             @"调用loadWorkingView方法前，workingView属性已经被置为有效值。");
    [self loadWorkingView];
    NSAssert(nil != _wrapperView,
             @"重写loadWorkingView方法时，workingView属性应该设置为有效值。");

    NSAssert([self isViewLoaded],
             @"调用loadSelfView方法前，view属性应该设置为有效值。");
    [self loadSelfView];
    NSAssert([self isViewLoaded],
             @"重写loadSelfView方法时，view属性应该设置为有效值。");

    if ([self respondsToSelector:@selector(didCustomizeView)]) {
        [self didCustomizeView];
    }
}

- (void)loadContentView
{
    UIView *contentView = [self view];
    id<UILayoutSupport> topLayoutGuide = [self topLayoutGuide];
    id<UILayoutSupport> bottomLayoutGuide = [self bottomLayoutGuide];
    NSArray *contentViewConstraints = [NSArray arrayWithArray:
                                       [contentView constraints]];

    // 遍历内容视图的约束，将与topLayoutGuide/bottomLayoutGuide相关的约束统一拷
    // 贝一份，并将其中的topLayoutGuide/bottomLayoutGuide修改为内容视图的上侧边
    // 和下侧边。

    for (NSLayoutConstraint *constraint in contentViewConstraints) {
        if (!constraint.firstItem || !constraint.secondItem) {
            continue;
        }
        if (topLayoutGuide == constraint.firstItem
            && contentView != constraint.secondItem)
        {
            [contentView addConstraint:
             [NSLayoutConstraint constraintWithItem:contentView
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:constraint.relation
                                             toItem:constraint.secondItem
                                          attribute:constraint.secondAttribute
                                         multiplier:constraint.multiplier
                                           constant:constraint.constant
                                           priority:constraint.priority]];
        }
        else if (contentView != constraint.firstItem
                 && topLayoutGuide == constraint.secondItem) {
            [contentView addConstraint:
             [NSLayoutConstraint constraintWithItem:constraint.firstItem
                                          attribute:constraint.firstAttribute
                                          relatedBy:constraint.relation
                                             toItem:contentView
                                          attribute:NSLayoutAttributeTop
                                         multiplier:constraint.multiplier
                                           constant:constraint.constant
                                           priority:constraint.priority]];
        }
        else if (bottomLayoutGuide == constraint.firstItem
                 && contentView != constraint.secondItem) {
            [contentView addConstraint:
             [NSLayoutConstraint constraintWithItem:contentView
                                          attribute:NSLayoutAttributeBottom
                                          relatedBy:constraint.relation
                                             toItem:constraint.secondItem
                                          attribute:constraint.secondAttribute
                                         multiplier:constraint.multiplier
                                           constant:constraint.constant
                                           priority:constraint.priority]];
        }
        else if (contentView != constraint.firstItem
                 && bottomLayoutGuide == constraint.secondItem) {
            [contentView addConstraint:
             [NSLayoutConstraint constraintWithItem:constraint.firstItem
                                          attribute:constraint.firstAttribute
                                          relatedBy:constraint.relation
                                             toItem:contentView
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:constraint.multiplier
                                           constant:constraint.constant
                                           priority:constraint.priority]];
        }
    }

    self.contentView = contentView;
}

- (void)loadWrapperView
{
    self.wrapperView = [[QPPanelWrapperView alloc] init];
    [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_wrapperView addSubview:_contentView];
    [_wrapperView setBackgroundColor:[UIColor clearColor]];

    // 当contentView可满足完全填充wrapperView时，则将其完全填充。否则将其放置在
    // wrapperView的正中心显示。并且当wrapperView不能完全显示contentView时，将
    // contentView的左上角与wrapperView的左上角重合显示。

    NSNumber *priority = @(QPLayoutPriorityFittingSize);
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
    NSDictionary *metrics = NSDictionaryOfVariableBindings(priority);

    QPVisualFormatBegin(_wrapperView, metrics, views);
    QPVisualFormat(@"H:|-(0@priority,>=0)-[_contentView]-(0@priority)-|");
    QPVisualFormat(@"V:|-(0@priority,>=0)-[_contentView]-(0@priority)-|");
    QPVisualFormatEnd();

    [_wrapperView addConstraint:
     [NSLayoutConstraint constraintWithItem:_contentView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_wrapperView
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0.0
                                   priority:QPLayoutPriorityHigh]];

    [_wrapperView addConstraint:
     [NSLayoutConstraint constraintWithItem:_contentView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:_wrapperView
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0
                                   constant:0.0
                                   priority:QPLayoutPriorityHigh]];
}

- (void)loadWorkingView
{
    self.workingView = [[QPPanelWorkingView alloc] init];
    [_wrapperView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_workingView addSubview:_wrapperView];
    [_workingView setBackgroundColor:[UIColor clearColor]];

    // 创建wrapperView的低优先级的顶部及底部附着到workingView的约束。用户还可以
    // 往顶部或底部插入其他带有高优先级约束的定制栏视图，从而让wrapperView自动缩
    // 放到合适的大小，以容纳新插入的定制栏视图。

    NSNumber *priority = @(QPLayoutPriorityLow);
    NSDictionary *views = NSDictionaryOfVariableBindings(_wrapperView);
    NSDictionary *metrics = NSDictionaryOfVariableBindings(priority);

    QPVisualFormatBegin(_workingView, metrics, views);
    QPVisualFormat(@"H:|[_wrapperView]|");
    QPVisualFormat(@"V:|-0@priority-[_wrapperView]-0@priority-|");
    QPVisualFormatEnd();
}

- (void)loadSelfView
{
    UIView *selfView = [[QPPanelSelfView alloc] init];
    [_workingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [selfView addSubview:_workingView];
    [selfView setBackgroundColor:[UIColor clearColor]];

    NSNumber *priority = @(QPLayoutPriorityHigh);
    NSDictionary *views = NSDictionaryOfVariableBindings(_workingView);
    NSDictionary *metrics = NSDictionaryOfVariableBindings(priority);

    QPVisualFormatBegin(selfView, metrics, views);
    QPVisualFormat(@"H:|[_workingView]|");
    QPVisualFormat(@"V:|-0@priority-[_workingView]-0@priority-|");
    QPVisualFormatEnd();

    self.view = selfView;
}

#pragma mark - 视图布局相关。

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // 获取状态栏底边的位置。

    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusBarBottom = CGRectGetMaxY(statusBarFrame);

    // 获取topLayoutGuide底边的位置。

    id<UILayoutSupport> topLayoutGuide = [self topLayoutGuide];
    CGRect topLayoutGuideFrame = [self.view bounds];
    topLayoutGuideFrame.size.height = [topLayoutGuide length];
    topLayoutGuideFrame = [self.view convertRect:topLayoutGuideFrame toView:nil];
    CGFloat topLayoutGuideBottom = CGRectGetMaxY(topLayoutGuideFrame);

    // 如果不是全屏页面，则建立workingView与topLayoutGuide之间的约束。

    if (topLayoutGuide && _workingView && topLayoutGuideBottom > statusBarBottom) {
        if (![self isConstraintRelationExistsBetween:_workingView
                                                 and:topLayoutGuide]) {
            NSDictionary *views = NSDictionaryOfVariableBindings(_workingView,
                                                                 topLayoutGuide);
            QPVisualFormatBegin(self.view, nil, views);
            QPVisualFormat(@"V:[topLayoutGuide][_workingView]");
            QPVisualFormatEnd();
        }
    }

    // 建立workingView与bottomLayoutGuide之间的约束。

    id<UILayoutSupport> bottomLayoutGuide = [self bottomLayoutGuide];
    if (bottomLayoutGuide && _workingView) {
        if (![self isConstraintRelationExistsBetween:_workingView
                                                 and:bottomLayoutGuide]) {
            NSDictionary *views = NSDictionaryOfVariableBindings(_workingView,
                                                                 bottomLayoutGuide);
            QPVisualFormatBegin(self.view, nil, views);
            QPVisualFormat(@"V:[_workingView][bottomLayoutGuide]");
            QPVisualFormatEnd();
        }
    }
}

- (BOOL)isConstraintRelationExistsBetween:(id)anObject
                                      and:(id)anotherObject
{
    BOOL isConstraintRelationExists = NO;

    for (NSLayoutConstraint *constraint in [self.view constraints]) {
        if ((constraint.firstItem == anObject &&
             constraint.secondItem == anotherObject) ||
            (constraint.firstItem == anotherObject &&
             constraint.secondItem == anObject)) {
                isConstraintRelationExists = YES;
                break;
            }
    }

    return isConstraintRelationExists;
}

#pragma mark - 支持定制栏。

- (void)setTopCustomBars:(NSArray *)topCustomBars
{
    if (topCustomBars == _topCustomBars) {
        return;
    }

    NSArray *fromTopCustomBars = _topCustomBars;
    NSArray *toTopCustomBars = topCustomBars;

    if ([self respondsToSelector:@selector(willChangeTopCustomBarsFrom:to:)]) {
        [self willChangeTopCustomBarsFrom:fromTopCustomBars
                                       to:toTopCustomBars];
    }

    // 将不在新顶部定制栏列表中的旧定制栏从界面上移除。

    for (UIView *customBar in _topCustomBars) {
        if (![topCustomBars containsObject:customBar]
            && _workingView == [customBar superview]) {
            [customBar removeFromSuperview];
        }
    }

    // 将不在workingView上的新顶部定制栏添加到界面上。

    for (UIView *customBar in topCustomBars) {
        if (_workingView && _workingView != [customBar superview]) {
            [_workingView addSubview:customBar];
        }
    }

    // 设置为新顶部定制栏列表并且刷新所有约束。

    _topCustomBars = topCustomBars;

    if (_workingView) {
        [self updateConstraintsWithCustomBars:_topCustomBars
                                containerView:_workingView
                                      topView:_workingView
                                   bottomView:_wrapperView];
    }

    if ([self respondsToSelector:@selector(didChangeTopCustomBarsFrom:to:)]) {
        [self didChangeTopCustomBarsFrom:fromTopCustomBars
                                      to:toTopCustomBars];
    }
}

- (void)setBottomCustomBars:(NSArray *)bottomCustomBars
{
    if (bottomCustomBars == _bottomCustomBars) {
        return;
    }

    NSArray *fromBottomCustomBars = _bottomCustomBars;
    NSArray *toBottomCustomBars = bottomCustomBars;

    if ([self respondsToSelector:@selector(willChangeBottomCustomBarsFrom:to:)]) {
        [self willChangeBottomCustomBarsFrom:fromBottomCustomBars
                                          to:toBottomCustomBars];
    }

    // 将不在新底部定制栏列表中的旧定制栏从界面上移除。

    for (UIView *customBar in _bottomCustomBars) {
        if (![bottomCustomBars containsObject:customBar]
            && _workingView == [customBar superview]) {
            [customBar removeFromSuperview];
        }
    }

    // 将不在workingView上的新底部定制栏添加到界面上。

    for (UIView *customBar in bottomCustomBars) {
        if (_workingView && _workingView != [customBar superview]) {
            [_workingView addSubview:customBar];
        }
    }

    // 设置为新底部定制栏列表并且刷新所有约束。

    _bottomCustomBars = bottomCustomBars;

    if (_workingView) {
        [self updateConstraintsWithCustomBars:_bottomCustomBars
                                containerView:_workingView
                                      topView:_wrapperView
                                   bottomView:_workingView];
    }

    if ([self respondsToSelector:@selector(didChangeBottomCustomBarsFrom:to:)]) {
        [self didChangeBottomCustomBarsFrom:fromBottomCustomBars
                                         to:toBottomCustomBars];
    }
}

- (void)addTopCustomBar:(UIView *)customBar
{
    NSMutableArray *customBars = [NSMutableArray array];
    [customBars addObjectsFromArray:_topCustomBars];
    [customBars addObject:customBar];
    [self setTopCustomBars:customBars];
}

- (void)addBottomCustomBar:(UIView *)customBar
{
    NSMutableArray *customBars = [NSMutableArray array];
    [customBars addObjectsFromArray:_bottomCustomBars];
    [customBars addObject:customBar];
    [self setBottomCustomBars:customBars];
}

- (void)removeCustomBar:(UIView *)customBar
{
    if ([_topCustomBars containsObject:customBar]) {
        NSMutableArray *customBars = [NSMutableArray array];
        [customBars addObjectsFromArray:_topCustomBars];
        [customBars removeObject:customBar];
        [self setTopCustomBars:customBars];
    }

    if ([_bottomCustomBars containsObject:customBar]) {
        NSMutableArray *customBars = [NSMutableArray array];
        [customBars addObjectsFromArray:_bottomCustomBars];
        [customBars removeObject:customBar];
        [self setBottomCustomBars:customBars];
    }
}

- (void)updateConstraintsWithCustomBars:(NSArray *)customBars
                          containerView:(UIView *)containerView
                                topView:(UIView *)topView
                             bottomView:(UIView *)bottomView
{
    NSUInteger count = [customBars count];
    NSDictionary *views;

    // 遍历所有定制栏，更新其与顶部视图、底部视图以及其它定制栏的约束。使得定制
    // 栏可以按照列表的顺序从上到下紧密排列。

    // 移除现存的定制栏之间的约束。

    NSMutableArray *oldConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in [containerView constraints]) {
        if ([customBars containsObject:constraint.firstItem]
            || [customBars containsObject:constraint.secondItem]) {
            [oldConstraints addObject:constraint];
        }
    }
    [containerView removeConstraints:oldConstraints];

    // 创建最上面的定制栏与顶部视图（或容器视图）之间的约束。

    if (count > 0) {
        UIView *customBar = [customBars firstObject];
        [customBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        views = NSDictionaryOfVariableBindings(topView, customBar);
        QPVisualFormatBegin(containerView, nil, views);
        QPVisualFormat((topView == containerView)
                       ? @"V:|[customBar]"
                       : @"V:[topView][customBar]");
        QPVisualFormat(@"H:|[customBar]|");
        QPVisualFormatEnd();
    }

    // 创建相邻定制栏之间的约束。

    for (NSUInteger i = 1; i < count; ++i) {
        UIView *customBar = [customBars objectAtIndex:i];
        UIView *aboveCustomBar = [customBars objectAtIndex:i - 1];
        [customBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        views = NSDictionaryOfVariableBindings(aboveCustomBar, customBar);
        QPVisualFormatBegin(containerView, nil, views);
        QPVisualFormat(@"V:[aboveCustomBar][customBar]");
        QPVisualFormat(@"H:|[customBar]|");
        QPVisualFormatEnd();
    }

    // 创建最下面的定制栏与底部视图（或容器视图）之间的约束。

    if (count > 0) {
        UIView *customBar = [customBars lastObject];
        views = NSDictionaryOfVariableBindings(customBar, bottomView);
        QPVisualFormatBegin(containerView, nil, views);
        QPVisualFormat((bottomView == containerView)
                       ? @"V:[customBar]|"
                       : @"V:[customBar][bottomView]");
        QPVisualFormatEnd();
    }

    [self.view setNeedsLayout];
}

#pragma mark - 清空视图缓存。

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    // 当view属性设置为nil值时，应当按照UIKit的资源管理规则，清空视图缓存。
    // 当view属性设置为有效值时，应当重新添加顶部及底部定制栏到工作视图上。

    if (object == self && [keyPath isEqualToString:@"view"]) {
        if ([change objectForKey:NSKeyValueChangeNewKey]) {
            if (_workingView && [_topCustomBars count] > 0) {
                [self setTopCustomBars:[NSArray arrayWithArray:_topCustomBars]];
            }
            if (_workingView && [_bottomCustomBars count] > 0) {
                [self setBottomCustomBars:[NSArray arrayWithArray:_bottomCustomBars]];
            }
        }
        else {
            [self setContentView:nil];
            [self setWrapperView:nil];
            [self setWorkingView:nil];
        }
    }
}

#pragma mark - QPApplicationFrameworkObject

- (void)refreshAppearance
{
    self.view.backgroundColor = [UIColor colorWithRGB:
                                 QPFoundationPanelBackgroundColor];

    if (QPFoundationPanelContentViewTransparent) {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end
