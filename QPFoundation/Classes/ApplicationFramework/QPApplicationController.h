//
//  QPApplicationController.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPApplicationFrameworkObject.h>

@class QPFullScreenNavigationController;
@class QPNavigationController;
@class QPTabBarController;

@interface QPApplicationController : UIResponder<QPApplicationFrameworkObject,
                                                 UIApplicationDelegate,
                                                 UINavigationControllerDelegate,
                                                 UITabBarControllerDelegate>

/**
 *  附在屏幕上的窗口视图，是整个应用程序视图层级的根视图。
 */
@property (nonatomic, strong) UIWindow *window;

/**
 *  全屏导航控制器，不带导航栏及工具栏，并将其作为window的根视图控制器。所有其它
 *  视图框架（如带有导航栏的pageNavigationController或者tabBarController）均使用
 *  全屏导航控制器推至屏幕上。
 *
 *  @see -[QPApplicationController loadFullScreenNavigationController]
 */
@property (nonatomic, strong, readonly) QPFullScreenNavigationController *fullScreenNavigationController;

/**
 *  页面导航控制器，默认带导航栏但不带工具栏。
 *
 *  @note 由外部参数QPFoundationIsEnablePageNavigationController控制是否启用，默
 *        认启用。
 *
 *  @see -[QPApplicationController loadPageNavigationController]
 */
@property (nonatomic, strong, readonly) QPNavigationController *pageNavigationController;

/**
 *  页面切换控制器。
 *
 *  @note 由外部参数QPFoundationIsEnableTabBarController控制是否启用，默认不启用。
 *
 *  @see -[QPApplicationController loadTabBarController]
 */
@property (nonatomic, strong, readonly) QPTabBarController *tabBarController;

/**
 *  初始化QPFoundation的首选项，默认不作任何操作，子类可以重写该方法，并对个别首
 *  选项进行定制设置。所有QPFoundation的选项都可以在下面的头文件中找到相关定义及
 *  设置说明：<QPFoundation/QPFoundationPreferences.h>。
 */
- (void)initializePreferences;

/**
 *  初始化页面切换控制器的视图控制器列表。如果启用默认的页面切换控制器，子类应该
 *  重写该方法，并返回初始的视图控制器列表。如果通过外部参数控制不启用页面切换控
 *  制器，或者自定义了页面切换控制器的加载行为，则不会调用该方法。
 */
- (NSArray *)initializeTabBarViewControllers;

/**
 *  安装应用程序框架对象，应用程序框架对象在初始化完成后会调用全局程序控制器的这
 *  个方法。安装的主要目的是为了建立委托关系、安装消息监听等。由于全部应用程序框
 *  架对象在初始化时都会回调到该方法，子类可以重写该方法，并且在回调父类的这个方
 *  法后实现定制的安装行为。
 */
- (void)installApplicationFrameworkObject:(id<QPApplicationFrameworkObject>)anObject;

/**
 *  加载全屏导航控制器，子类可以重写该方法返回定制的全屏导航控制器。
 */
- (QPFullScreenNavigationController *)loadFullScreenNavigationController;

/**
 *  加载页面导航控制器，子类可以重写该方法返回定制的页面导航控制器。
 */
- (QPNavigationController *)loadPageNavigationController;

/**
 *  加载页面切换控制器，子类可以重写该方法返回定制的页面切换控制器。
 */
- (QPTabBarController *)loadTabBarController;

/**
 *  应用程序启动行为，在Application Framework初始化完成后调用。默认什么事情也不
 *  做，子类可以重写该方法实现定制的应用程序启动行为。
 */
- (void)launching;

/**
 *  应用程序退出行为，一般用于清理系统缓存等。默认什么事情也不做，子类可以重写该
 *  方法实现定制的应用程序退出行为。
 */
- (void)terminate;

@end
