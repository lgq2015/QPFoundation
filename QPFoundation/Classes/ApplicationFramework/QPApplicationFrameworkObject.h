//
//  QPApplicationFrameworkObject.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/2.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/NSObject+Association.h>


@protocol QPApplicationFrameworkObject <NSObject>

@required

/**
 *  初始化应用程序框架对象，一般是调用完init/initWithXXX后立即调用。并且保证同一
 *  个对象会且只会调用一次，不会因为init/initWithXXX之间的来回调用而被重复执行。
 *
 *  @note 子类在重写该方法时，需要首先调用父类的该方法。
 */
- (void)initializeObject;

@optional

/**
 *  更新界面样式。调用QPGetApplicationController()的这个方法可以刷新整个程序的界
 *  面样式。具体的界面样式设置选项详见<QPFoundation/QPFoundationPreferences.h>文件。
 */
- (void)refreshAppearance;

@end


/**
 *  应用程序框架对象的初始化方法预定义宏，必须使用这组宏来为框架内的对象提供初始
 *  化方法，否则可能无法正常使用依赖应用程序框架对象初始化过程的部份功能。如果你
 *  需要在对象初始化时定制自己的初始化行为，可以实现QPApplicationFrameworkObject
 *  协议的initializeObject方法并在其中进行定制。
 */
#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(declare, calling)           \
    declare                                                                     \
    {                                                                           \
        Class selfClass = [self class];                                         \
        QPEnterApplicationFrameworkObjectInitializeProcess(selfClass);          \
        self = (calling);                                                       \
        QPInitializeApplicationFrameworkObject(self);                           \
        QPLeaveApplicationFrameworkObjectInitializeProcess(selfClass);          \
        return self;                                                            \
    }                                                                           \

#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_init                        \
    QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(                                \
        - (instancetype)init,                                                   \
        [super init]                                                            \
    )                                                                           \

#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithCoder               \
    QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(                                \
        - (instancetype)initWithCoder:(NSCoder *)aDecoder,                      \
        [super initWithCoder:aDecoder]                                          \
    )                                                                           \

#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithFrame               \
    QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(                                \
        - (instancetype)initWithFrame:(CGRect)frame,                            \
        [super initWithFrame:frame]                                             \
    )                                                                           \

#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithNibName_bundle      \
    QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(                                \
        - (instancetype)initWithNibName:(NSString *)nibNameOrNil                \
                                 bundle:(NSBundle *)nibBundleOrNil,             \
        [super initWithNibName:nibNameOrNil                                     \
                        bundle:nibBundleOrNil]                                  \
    )                                                                           \

#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithNavigationBarClass_toolbarClass \
    QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(                                \
        - (instancetype)initWithNavigationBarClass:(Class)navigationBarClass    \
                                     toolbarClass:(Class)toolbarClass,          \
        [super initWithNavigationBarClass:navigationBarClass                    \
                        toolbarClass:toolbarClass]                              \
    )                                                                           \

#define QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER_initWithRootViewController  \
    QP_APPLICATION_FRAMEWORK_OBJECT_INITIALIZER(                                \
        - (instancetype)initWithRootViewController:(UIViewController *)rootViewController, \
        [super initWithRootViewController:rootViewController]                   \
    )                                                                           \
