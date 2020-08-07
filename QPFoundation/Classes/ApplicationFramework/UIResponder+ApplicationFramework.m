//
//  UIResponder+ApplicationFramework.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/11.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIResponder+ApplicationFramework.h>
#import <QPFoundation/QPApplicationFramework.h>

@implementation UIResponder (ApplicationFramework)

- (instancetype)init
{
    self = [super init];
    if (self) {

        // 从全局的原生类<=>Application Framework Object Class对应关系列表中提取
        // 当前类的替换信息。

        NSDictionary *cover = QPGetApplicationFrameworkObjectClassCover([self class]);
        Class frameworkClass = [cover objectForKey:QPApplicationFrameworkObjectClass];
        NSArray *containerClasses = [cover objectForKey:QPContainerClasses];

        // 如果存在可以替换的应用程序框架对象类，则创建替换类的实例并返回。

        if (frameworkClass && containerClasses) {

            // 取出当前正在初始化的父容器的堆栈。

            NSArray *initializeStack = QPGetApplicationFrameworkObjectsInitializeStack();

            // 判断父容器的类型是否符合替换条件。

            BOOL isContainerInitializing = NO;
            for (Class initializingClass in initializeStack) {
                for (Class containerClass in containerClasses) {
                    if ([initializingClass isSubclassOfClass:containerClass]) {
                        isContainerInitializing = YES;
                        break;
                    }
                }
                if (isContainerInitializing) {
                    break;
                }
            }

            // 如果符合替换条件，则新创建替换类的实例，并初始化父类UIResponder以
            // 上的部份，其它初始化行为则在本方法返回后由原生类的初始化函数完成。
            // 有鉴于此，如果是原生类替换为应用程序框架对象类的情况，则在原生类
            // 初始化函数调用完成后，应用程序框架对象类实例其实仍未被完全初始化，
            // 所以需要在父容器的initializeObject中手动对被替换类的实例进行初始
            // 化。例如UITabBar替换为QPTabBar时，需要在父容器QPTabBarController的
            // 初始化方法-initializeObject中手工进行QPTabBar的初始化。

            if (isContainerInitializing) {
                self = [frameworkClass alloc];
                self = [super init];
            }
        }
    }
    return self;
}

@end
