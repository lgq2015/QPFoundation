//
//  QPApplicationFramework.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPApplicationFrameworkObject.h>
#import <QPFoundation/UIResponder+ApplicationFramework.h>
#import <QPFoundation/QPApplicationController.h>

#import <QPFoundation/QPFullScreenNavigationController.h>
#import <QPFoundation/QPNavigationController.h>
#import <QPFoundation/QPNavigationBar.h>
#import <QPFoundation/QPToolbar.h>
#import <QPFoundation/QPTabBarController.h>
#import <QPFoundation/QPTabBar.h>

#import <QPFoundation/QPBaseViewController.h>
#import <QPFoundation/QPPanelController.h>
#import <QPFoundation/QPCustomBar.h>
#import <QPFoundation/QPScrollPanelController.h>
#import <QPFoundation/QPLinker.h>


/**
 *  所有Application Framework Object用于更新界面样式的通知。一般在应用程序框架对
 *  象被调用QPInstallApplicationFrameworkObject()函数安装时，会默认将该通知安装
 *  到对象上并将其refreshAppearance方法作为响应函数。
 */
QP_EXPORT_KEYNAME(QPRefreshAppearanceNotification);

/**
 *  原生类<=>Application Framework Object Class对应关系字典中替代类的键名。
 */
QP_EXPORT_KEYNAME(QPApplicationFrameworkObjectClass);

/**
 *  原生类<=>Application Framework Object Class对应关系字典中容器类列表的键名。
 */
QP_EXPORT_KEYNAME(QPContainerClasses);


#pragma mark - 支撑Application Framework相关操作。

/**
 *  获取Application Framework Object的初始化堆栈。
 *
 *  @see QPEnterApplicationFrameworkObjectInitializeProcess()
 *       QPLeaveApplicationFrameworkObjectInitializeProcess()
 */
FOUNDATION_EXPORT NSMutableArray *QPGetApplicationFrameworkObjectsInitializeStack(void);

/**
 *  进入Application Framework Object的初始化进程。
 *
 *  @see QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER()
 */
FOUNDATION_EXPORT void QPEnterApplicationFrameworkObjectInitializeProcess(Class applicationFrameworkObjectClass);

/**
 *  离开Application Framework Object的初始化进程。
 *
 *  @see QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER()
 */
FOUNDATION_EXPORT void QPLeaveApplicationFrameworkObjectInitializeProcess(Class applicationFrameworkObjectClass);

/**
 *  安装应用程序框架对象，详见-installApplicationFrameworkObject:方法。
 *
 *  @see -[QPApplicationController installApplicationFrameworkObject:]
 */
FOUNDATION_EXPORT void QPInstallApplicationFrameworkObject(id<QPApplicationFrameworkObject> anObject);

/**
 *  初始化应用程序框架对象，会首先调用对象的-initializeObject方法进行初始化，然
 *  后调用QPInstallApplicationFrameworkObject()函数将其安装到应用程序框架中来。
 *
 *  @see -[QPApplicationFrameworkObject initializeObject]
 *       QPInstallApplicationFrameworkObject()
 */
FOUNDATION_EXPORT void QPInitializeApplicationFrameworkObject(id<QPApplicationFrameworkObject> anObject);

/**
 *  获取原生类<=>Application Framework Object Class对应关系字典。
 */
FOUNDATION_EXPORT NSMutableDictionary *QPGetApplicationFrameworkObjectClassCovers(void);

/**
 *  设置原生类<=>Application Framework Object Class对应关系。
 */
FOUNDATION_EXPORT void QPSetApplicationFrameworkObjectClassCover(Class intrinsicClass,
                                                                 Class applicationFrameworkObjectClass,
                                                                 NSArray *containerClasses);

/**
 *  获取原生类<=>Application Framework Object Class对应关系。
 */
FOUNDATION_EXPORT NSDictionary *QPGetApplicationFrameworkObjectClassCover(Class intrinsicClass);


#pragma mark - 获取UIApplication相关对象。

/**
 *  获取UIApplication的keyWindow对象。
 */
FOUNDATION_EXPORT UIWindow *QPGetKeyWindow(void);

/**
 *  获取UIApplication的委托对象。
 */
FOUNDATION_EXPORT id<UIApplicationDelegate> QPGetApplicationDelegate(void);

/**
 *  获取当前屏幕上视图体系或视图控制器体系中的第一响应者，通常为当前正在进行输入
 *  操作的文本框对象，如UITextField或UITextView。
 */
FOUNDATION_EXPORT id QPGetFirstResponder(void);

/**
 *  获取当前响应者的下一个匹配指定类的响应者。
 */
FOUNDATION_EXPORT id QPGetNextResponder(UIResponder *currentResponder, Class nextResponderClass);

/**
 *  获取当前视图的父视图体系中指定类型的视图。
 */
FOUNDATION_EXPORT id QPGetAscendantView(UIView *currentView, Class ascendantViewClass);

/**
 *  获取当前视图的子视图体系中指定类型的视图。
 */
FOUNDATION_EXPORT id QPGetDescendantView(UIView *currentView, Class descendantViewClass);

/**
 *  获取当前视图的子视图体系中指定类型的所有视图。
 */
FOUNDATION_EXPORT NSArray *QPGetDescendantViews(UIView *currentView, Class descendantViewClass);


#pragma mark - 获取Application Framework相关对象。

/**
 *  获取应用程序控制器。
 */
FOUNDATION_EXPORT QPApplicationController *QPGetApplicationController(void);

/**
 *  获取应用程序控制器辖下的window对象。
 */
FOUNDATION_EXPORT UIWindow *QPGetWindow(void);

/**
 *  获取应用程序控制器辖下的全屏导航控制器。
 */
FOUNDATION_EXPORT QPFullScreenNavigationController *QPGetFullScreenNavigationController(void);

/**
 *  获取应用程序控制器辖下的页面导航控制器。
 */
FOUNDATION_EXPORT QPNavigationController *QPGetPageNavigationController(void);

/**
 *  获取应用程序控制器辖下的页面切换控制器。
 */
FOUNDATION_EXPORT QPTabBarController *QPGetTabBarController(void);
