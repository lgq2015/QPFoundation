//
//  QPApplicationController.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPApplicationController.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/NSNotificationCenter+Autoremove.h>
#import <QPFoundation/NSObject+Association.h>
#import <QPFoundation/UINavigationItem+Assignment.h>


@interface QPApplicationController ()

@property (nonatomic, strong) QPFullScreenNavigationController *fullScreenNavigationController;
@property (nonatomic, strong) QPNavigationController *pageNavigationController;
@property (nonatomic, strong) QPTabBarController *tabBarController;

@end


@implementation QPApplicationController

#pragma mark - 程序启动校验。

+ (void)load
{
    if (![NSObject instancesRespondToSelector:@selector(associatedValueForKey:)]) {
        [NSException raise:@"QPFoundationUsageException" format:
         @"[QPFoundation] Before import QPFoundation.framework into your projects, "
         @"you must add `-ObjC' into your project's `Other Linker Flags' option."];
    }
}

#pragma mark - 初始化及销毁。

QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init

- (void)initializeObject
{
    // Nothing to do.
}

- (void)initializePreferences
{
    // 所有选项的初始化工作已经在选项变量声明的同时进行初始化，这里不作任何处理。
    // 但子类可以通过重写该方法，在程序初始化之前合适的时机，对QPFoundation进行定
    // 制化的设置。例如可以定义是否启用tabBarController、定义导航栏的背景图片等。
    // 所有首选项的初始化设置可以详见QPFoundationPreferences.m文件。
}

- (NSArray *)initializeTabBarViewControllers
{
    NSLog(@"[QPFoundation] warning: You should override "
          @"`-initializeTabBarViewControllers' method "
          @"to initialize tabBarController's viewControllers.");
    return nil;
}

- (void)installApplicationFrameworkObject:(id<QPApplicationFrameworkObject>)anObject
{
    // 为框架对象安装委托到全局程序控制器。

    if ([anObject respondsToSelector:@selector(setDelegate:)]) {
        if ([anObject isKindOfClass:[QPNavigationController class]]
            || [anObject isKindOfClass:[QPTabBarController class]]) {
            [(id)anObject setDelegate:self];
        }
    }

    // 为框架对象安装刷新界面样式的通知。

    if ([anObject respondsToSelector:@selector(refreshAppearance)]) {
        if (![anObject isKindOfClass:[QPApplicationController class]]
            && ![anObject isKindOfClass:[QPNavigationController class]]
            && ![anObject isKindOfClass:[QPTabBarController class]]) {

            // 为不影响视图控制器关联视图的生命周期，这里仅当对象是UIView的子类
            // 时才立即进行界面样式的刷新，而其它类型的对象都延后一个消息循环周
            // 期再进行界面样式的刷新。

            if ([anObject isKindOfClass:[UIView class]]) {
                [anObject refreshAppearance];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [anObject refreshAppearance];
                });
            }

            // 安装刷新界面样式的通知，并在对象销毁前自动移除通知的监听。

            NSNotificationCenter *notificationCenter;
            notificationCenter = [NSNotificationCenter defaultCenter];

            [notificationCenter addObserver:anObject
                                   selector:@selector(refreshAppearance)
                                       name:QPRefreshAppearanceNotification
                                     object:nil];

            [notificationCenter autoremoveObserver:anObject];
        }
    }
}

#pragma mark - 应用程序入口。

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    // 初始化QPFoundation的首选项。

    [self initializePreferences];

    // 创建附在屏幕上的窗口视图。

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // 创建全屏导航控制器，并作为window的根视图控制器。

    NSAssert(nil == self.fullScreenNavigationController,
             @"调用loadFullScreenNavigationController方法前，"
             @"已经存在有效的全屏导航控制器。");

    self.fullScreenNavigationController = [self loadFullScreenNavigationController];

    NSAssert(nil != self.fullScreenNavigationController,
             @"重写loadFullScreenNavigationController方法时，"
             @"必须返回有效的全屏导航控制器。");

    self.window.rootViewController = self.fullScreenNavigationController;

    // 创建页面导航控制器，默认带有导航栏，但不带工具栏。

    if (QPFoundationIsEnablePageNavigationController) {
        NSAssert(nil == self.pageNavigationController,
                 @"调用loadPageNavigationController方法前，"
                 @"已经存在有效的页面导航控制器。");

        self.pageNavigationController = [self loadPageNavigationController];

        NSAssert(nil != self.pageNavigationController,
                 @"重写loadPageNavigationController方法时，"
                 @"必须返回有效的页面导航控制器。");
    }

    // 创建页面切换控制器，并推至全屏或者推至页面导航控制器内。

    if (QPFoundationIsEnableTabBarController) {
        NSAssert(nil == self.tabBarController,
                 @"调用loadTabBarController方法前，"
                 @"已经存在有效的页面切换控制器。");

        self.tabBarController = [self loadTabBarController];

        NSAssert(nil != self.tabBarController,
                 @"重写loadTabBarController方法时，"
                 @"必须返回有效的页面切换控制器。");
    }

    // 将页面导航控制器/页面切换控制器推至全屏。

    if (QPFoundationIsPrepushingFrameworkController) {
        QPNavigationController *navigationController;
        navigationController = self.fullScreenNavigationController;

        if (self.pageNavigationController) {
            [navigationController pushViewController:self.pageNavigationController
                                            animated:NO];
            navigationController = self.pageNavigationController;
        }

        if (self.tabBarController) {
            [navigationController pushViewController:self.tabBarController
                                            animated:NO];
        }
    }

    // 将窗口视图放到屏幕上，并作为UIApplication的keyWindow。

    [self.window makeKeyAndVisible];

    // 调用用户定制的应用程序启动行为。

    [self launching];

    return YES;
}

- (QPFullScreenNavigationController *)loadFullScreenNavigationController
{
    QPFullScreenNavigationController *instance;

    instance = [[QPFullScreenNavigationController alloc] init];
    instance.delegate = self;
    instance.navigationBarHidden = YES;
    instance.toolbarHidden = YES;

    return instance;
}

- (QPNavigationController *)loadPageNavigationController
{
    QPNavigationController *instance;

    instance = [[QPNavigationController alloc] init];
    instance.delegate = self;
    instance.navigationBarHidden = NO;
    instance.toolbarHidden = YES;

    return instance;
}

- (QPTabBarController *)loadTabBarController
{
    QPTabBarController *instance;

    instance = [[QPTabBarController alloc] init];
    instance.delegate = self;

    // 添加用户定制的视图控制器列表到tabBarController中。

    NSArray *tabBarViewControllers = [self initializeTabBarViewControllers];

    if ([tabBarViewControllers count] > 0) {
        if (QPFoundationIsEnableNavigationControllerPerTabBarItem) {
            NSMutableArray *viewControllers = [NSMutableArray array];
            QPNavigationController *navigationController = nil;
            BOOL navigationBarHidden = QPFoundationIsEnablePageNavigationController;
            for (UIViewController *viewController in tabBarViewControllers) {

                // 创建包裹tarBarItem对应页面视图控制器的页面导航控制器。

                navigationController = [[QPNavigationController alloc] init];
                navigationController.navigationBarHidden = navigationBarHidden;
                navigationController.toolbarHidden = YES;
                navigationController.tabBarItem = viewController.tabBarItem;

                // 将页面导航控制器加入到tarBar的视图控制器列表。

                [navigationController pushViewController:viewController
                                                animated:NO];
                [viewControllers addObject:navigationController];
            }
            [instance setViewControllers:viewControllers];
        }
        else {
            [instance setViewControllers:tabBarViewControllers];
        }
    }

    return instance;
}

- (void)launching
{
    // Nothing to do.
}

#pragma mark - 应用程序出口。

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self terminate];
}

- (void)terminate
{
    // Nothing to do.
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    // 切换页面的同时将导航项切换为选中页面的导航项。

    if (QPFoundationIsEnableTabBarControllerSwitchNavigationItem) {
        [tabBarController.navigationItem
         assignCopy:viewController.navigationItem];
    }
}

#pragma mark - QPApplicationFrameworkObject

- (void)refreshAppearance
{
    // 发送更新界面样式通知到全部架框界面对象。

    [[NSNotificationCenter defaultCenter]
     postNotificationName:QPRefreshAppearanceNotification
     object:self];
}

@end
