//
//  QPApplicationFramework.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/30.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/NSObject+Association.h>


QP_DEFINE_KEYNAME(QPRefreshAppearanceNotification);
QP_DEFINE_KEYNAME(QPApplicationFrameworkObjectClass);
QP_DEFINE_KEYNAME(QPContainerClasses);


#pragma mark - 支撑Application Framework相关操作。

NSMutableArray *QPGetApplicationFrameworkObjectsInitializeStack()
{
    QP_STATIC_KEYNAME(QPApplicationFrameworkObjectsInitializeStack);
    NSString *key = QPApplicationFrameworkObjectsInitializeStack;

    NSThread *currentThread = [NSThread currentThread];
    NSMutableDictionary *threadDictionary = [currentThread threadDictionary];
    NSMutableArray *initializeStack = [threadDictionary objectForKey:key];

    if (!initializeStack) {
        initializeStack = [NSMutableArray array];
        [threadDictionary setValue:initializeStack forKey:key];
    }

    return initializeStack;
}

void QPEnterApplicationFrameworkObjectInitializeProcess(Class applicationFrameworkObjectClass)
{
    NSMutableArray *initializeStack = QPGetApplicationFrameworkObjectsInitializeStack();
    [initializeStack addObject:applicationFrameworkObjectClass];
}

void QPLeaveApplicationFrameworkObjectInitializeProcess(Class applicationFrameworkObjectClass)
{
    NSMutableArray *initializeStack = QPGetApplicationFrameworkObjectsInitializeStack();

    NSCAssert2([initializeStack count] > 0
               && [initializeStack lastObject] == applicationFrameworkObjectClass,
               @"[QPFoundation] Application framework objects initialize order error, "
               @"that the last object should be `%@', but the actual that is %@.",
               applicationFrameworkObjectClass,
               initializeStack);

    [initializeStack removeLastObject];
}

void QPInstallApplicationFrameworkObject(id<QPApplicationFrameworkObject> anObject)
{
    QP_STATIC_KEYNAME(QPIsApplicationFrameworkObjectInstalled);
    NSString *key = QPIsApplicationFrameworkObjectInstalled;

    if (anObject && ![[(id)anObject associatedValueForKey:key] boolValue]) {
        [(id)anObject setAssociatedValue:@(YES) forKey:key];
        [QPGetApplicationController() installApplicationFrameworkObject:anObject];
    }
}

void QPInitializeApplicationFrameworkObject(id<QPApplicationFrameworkObject> anObject)
{
    QP_STATIC_KEYNAME(QPIsApplicationFrameworkObjectInitialized);
    NSString *key = QPIsApplicationFrameworkObjectInitialized;

    if (anObject && ![[(id)anObject associatedValueForKey:key] boolValue]) {
        [(id)anObject setAssociatedValue:@(YES) forKey:key];

        if ([anObject respondsToSelector:@selector(willInitializeObject)]) {
            [(id)anObject willInitializeObject];
        }

        if ([anObject respondsToSelector:@selector(initializeObject)]) {
            [(id)anObject initializeObject];
        }

        if ([anObject respondsToSelector:@selector(didInitializeObject)]) {
            [(id)anObject didInitializeObject];
        }

        QPInstallApplicationFrameworkObject(anObject);
    }
}

NSMutableDictionary *QPGetApplicationFrameworkObjectClassCovers()
{
    static NSMutableDictionary *covers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        covers = [NSMutableDictionary dictionary];
    });
    return covers;
}

void QPSetApplicationFrameworkObjectClassCover(Class intrinsicClass,
                                               Class applicationFrameworkObjectClass,
                                               NSArray *containerClasses)
{
    NSMutableDictionary *covers = QPGetApplicationFrameworkObjectClassCovers();
    [covers setValue:@{QPApplicationFrameworkObjectClass:applicationFrameworkObjectClass,
                       QPContainerClasses:containerClasses}
              forKey:NSStringFromClass(intrinsicClass)];
}

NSDictionary *QPGetApplicationFrameworkObjectClassCover(Class intrinsicClass)
{
    NSMutableDictionary *covers = QPGetApplicationFrameworkObjectClassCovers();
    return [covers objectForKey:NSStringFromClass(intrinsicClass)];
}


#pragma mark - 获取UIApplication相关对象。

UIWindow *QPGetKeyWindow()
{
    return [[UIApplication sharedApplication] keyWindow];
}

id<UIApplicationDelegate> QPGetApplicationDelegate()
{
    return [[UIApplication sharedApplication] delegate];
}

id QPGetFirstResponder()
{
    id firstResponder = nil;

    // 尝试从屏幕视图体系上查找。

    UIWindow *window = QPGetKeyWindow();
    if (window) {
        NSMutableArray *views = [NSMutableArray arrayWithObject:window];
        for (NSUInteger index = 0; index < [views count]; ++index) {
            UIView *view = [views objectAtIndex:index];
            if ([view isFirstResponder]) {
                firstResponder = view;
                return firstResponder;
            }
            [views addObjectsFromArray:[view subviews]];
        }
    }

    // 尝试从视图控制器体系上查找。

    UIViewController *rootViewController = [window rootViewController];
    if (rootViewController) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithObject:rootViewController];
        for (NSUInteger index = 0; index < [viewControllers count]; ++index) {
            UIViewController *viewController = [viewControllers objectAtIndex:index];
            if ([viewController isFirstResponder]) {
                firstResponder = viewController;
                return firstResponder;
            }
            [viewControllers addObjectsFromArray:[viewController childViewControllers]];
        }
    }

    return nil;
}

id QPGetNextResponder(UIResponder *currentResponder, Class nextResponderClass)
{
    UIResponder *nextResponder = nil;

    for (; currentResponder; currentResponder = [currentResponder nextResponder]) {
        if ([currentResponder isKindOfClass:nextResponderClass]) {
            nextResponder = currentResponder;
            break;
        }
    }

    return nextResponder;
}

id QPGetAscendantView(UIView *currentView, Class ascendantViewClass)
{
    UIView *ascendantView = nil;

    for (; currentView; currentView = [currentView superview]) {
        if ([currentView isKindOfClass:ascendantViewClass]) {
            ascendantView = currentView;
            break;
        }
    }

    return ascendantView;
}

id QPGetDescendantView(UIView *currentView, Class descendantViewClass)
{
    UIView *descendantView = nil;
    NSMutableArray *subviews = [[NSMutableArray alloc] init];

    if (currentView) {
        [subviews addObject:currentView];
    }

    for (NSInteger index = 0; index < [subviews count]; ++index) {
        UIView *currentView = [subviews objectAtIndex:index];
        if ([currentView isKindOfClass:descendantViewClass]) {
            descendantView = currentView;
            break;
        }
        [subviews addObjectsFromArray:[currentView subviews]];
    }

    return descendantView;
}

NSArray *QPGetDescendantViews(UIView *currentView, Class descendantViewClass)
{
    NSMutableArray *descendantViews = [NSMutableArray array];
    NSMutableArray *subviews = [[NSMutableArray alloc] init];

    if (currentView) {
        [subviews addObject:currentView];
    }

    for (NSInteger index = 0; index < [subviews count]; ++index) {
        UIView *currentView = [subviews objectAtIndex:index];
        if ([currentView isKindOfClass:descendantViewClass]) {
            [descendantViews addObject:currentView];
        }
        [subviews addObjectsFromArray:[currentView subviews]];
    }

    return descendantViews;
}


#pragma mark - 获取Application Framework相关对象。

QPApplicationController *QPGetApplicationController()
{
    id applicationDelegate = QPGetApplicationDelegate();
    if (![applicationDelegate isKindOfClass:[QPApplicationController class]]) {
        applicationDelegate = nil;
    }
    return (QPApplicationController *)applicationDelegate;
}

UIWindow *QPGetWindow()
{
    return [QPGetApplicationController() window];
}

QPFullScreenNavigationController *QPGetFullScreenNavigationController()
{
    return [QPGetApplicationController() fullScreenNavigationController];
}

QPNavigationController *QPGetPageNavigationController()
{
    return [QPGetApplicationController() pageNavigationController];
}

QPTabBarController *QPGetTabBarController()
{
    return [QPGetApplicationController() tabBarController];
}
