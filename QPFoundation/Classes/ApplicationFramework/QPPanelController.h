//
//  QPPanelController.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPBaseViewController.h>
#import <QPFoundation/QPApplicationFrameworkObject.h>

@interface QPPanelController : QPBaseViewController<QPApplicationFrameworkObject>

/**
 *  内容视图，是wrapperView的唯一一个子视图。即视图控制器的关联视图，用户可以在
 *  xib或者storyboard中画出其轮廓，然后在视图控制器初始化时自动关联该视图。与以
 *  往将加载后的视图赋值给self.view不同的是，QPPanelController会将其赋值给新添加
 *  的self.contentView属性，而self.view则会被赋值为一个新创建的视图，并且这个新
 *  创建的视图会间接包裹contentView。子类可以重写其加载方法loadContentView实现定
 *  制的加载行为。
 *
 *  @see -[QPPanelController loadContentView]
 */
@property (nonatomic, strong) UIView *contentView;

/**
 *  包装视图，是workingView的其中一个子视图。用来包裹contentView，主要起到展示以
 *  及上下滚动浏览内容视图的作用。子类可以重写其加载方法loadWrapperView实现定制
 *  的加载行为，例如QPScrollPanelController使用UIScrollView来作为包装视图，可以
 *  支持上下滚动浏览内容视图。
 *
 *  @see -[QPPanelController loadWrapperView]
 */
@property (nonatomic, strong) UIView *wrapperView;

/**
 *  工作视图，是self.view的唯一一个子视图。用来包裹wrapperView以及所有顶部、底部
 *  定制栏topCustomBars、bottomCustomBars，主要起到调整整个页面的上下边距的作用。
 *  子类可以重写其加载方法loadWorkingView实现定制的加载行为。
 *
 *  @see -[QPPanelController loadWorkingView]
 */
@property (nonatomic, strong) UIView *workingView;

/**
 *  顶部定制栏列表，列表按从上到下的顺序排列，相邻两个定制栏紧密相连。所有定制栏
 *  都会添加到workingView上，并且由于使用优先级为QPLayoutPriorityLow的约束来压缩
 *  定制栏的高度，所以如果想要保持定制栏的高度不被该约束压缩，则需要使用优化级高
 *  于QPLayoutPriorityLow的约束来限定定制栏的高度，例如使用强制约束进行限定。
 *
 *  @see -[QPPanelController addTopCustomBar:]
 */
@property (nonatomic, copy) NSArray *topCustomBars;

/**
 *  底部定制栏列表，列表按从上到下的顺序排列，相邻两个定制栏紧密相连。所有定制栏
 *  都会添加到workingView上，并且由于使用优先级为QPLayoutPriorityLow的约束来压缩
 *  定制栏的高度，所以如果想要保持定制栏的高度不被该约束压缩，则需要使用优化级高
 *  于QPLayoutPriorityLow的约束来限定定制栏的高度，例如使用强制约束进行限定。
 *
 *  @see -[QPPanelController addBottomCustomBar:]
 */
@property (nonatomic, copy) NSArray *bottomCustomBars;

/**
 *  加载内容视图，由框架自动调用。子类可以重写该方法实现定制的加载行为。
 */
- (void)loadContentView;

/**
 *  加载包装视图，由框架自动调用。子类可以重写该方法实现定制的加载行为。
 */
- (void)loadWrapperView;

/**
 *  加载工作视图，由框架自动调用。子类可以重写该方法实现定制的加载行为。
 */
- (void)loadWorkingView;

/**
 *  添加顶部定制栏。可以添加QPCustomBar及其子类，或者一般类型的UIView。但推荐使
 *  用+[QPCustomBar customBarWithView:]来进行包裹。
 */
- (void)addTopCustomBar:(UIView *)customBar;

/**
 *  添加底部定制栏。可以添加QPCustomBar及其子类，或者一般类型的UIView。但推荐使
 *  用+[QPCustomBar customBarWithView:]来进行包裹。
 */
- (void)addBottomCustomBar:(UIView *)customBar;

/**
 *  从顶部或底部定制栏列表中移除指定定制栏。
 */
- (void)removeCustomBar:(UIView *)customBar;

@end

/**
 *  与QPPanelController相关的非正式协议，框架使用者可以在QPPanelController的子类
 *  或父类QPBaseViewController的类别中实现这些方法，从而在特定事件发生时可以进行
 *  一些定制化的处理。
 */
@interface NSObject (QPPanelController)

/**
 *  当QPPanelController调用initializeObject初始化应用程序框架对象前，回调该方法。
 *  子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)willInitializeObject;

/**
 *  当QPPanelController调用initializeObject初始化应用程序框架对象后，回调该方法。
 *  子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)didInitializeObject;

/**
 *  当QPPanelController从xib或storyboard加载完原始的视图对象后，准备对其进行包装
 *  处理前，回调该方法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)willCustomizeView;

/**
 *  当QPPanelController从xib或storyboard加载完原始的视图对象，并对其进行包装处理
 *  后，回调该方法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)didCustomizeView;

/**
 *  当QPPanelController添加/移除顶部定制栏，或者变更定制栏的排列位置前，回调该方
 *  法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)willChangeTopCustomBarsFrom:(NSArray *)fromTopCustomBars
                                 to:(NSArray *)toTopCustomBars;

/**
 *  当QPPanelController添加/移除顶部定制栏，或者变更定制栏的排列位置后，回调该方
 *  法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)didChangeTopCustomBarsFrom:(NSArray *)fromTopCustomBars
                                to:(NSArray *)toTopCustomBars;

/**
 *  当QPPanelController添加/移除底部定制栏，或者变更定制栏的排列位置前，回调该方
 *  法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)willChangeBottomCustomBarsFrom:(NSArray *)fromBottomCustomBars
                                    to:(NSArray *)toBottomCustomBars;

/**
 *  当QPPanelController添加/移除底部定制栏，或者变更定制栏的排列位置后，回调该方
 *  法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)didChangeBottomCustomBarsFrom:(NSArray *)fromBottomCustomBars
                                   to:(NSArray *)toBottomCustomBars;

@end
