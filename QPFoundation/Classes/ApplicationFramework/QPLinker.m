//
//  QPLinker.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/15.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPLinker.h>
#import <QPFoundation/NSObject+Association.h>
#import <QPFoundation/NSObject+Swizzling.h>
#import <QPFoundation/UITabBarItem+Assignment.h>


/**
 *  目标视图控制器是通过storyboard加载的。
 *
 *  @see +targetWithURLString:
 */
QP_STATIC_STRING(QPLinkerSchemeStoryboard, @"storyboard");

/**
 *  目标视图控制器是通过类名直接创建的。
 *
 *  @see +targetWithURLString:
 */
QP_STATIC_STRING(QPLinkerSchemeViewController, @"view-controller");

/**
 *  目标视图控制器是通过类名直接创建的。是view-controller协议的简单写法。
 *
 *  @see +targetWithURLString:
 */
QP_STATIC_STRING(QPLinkerSchemeClass, @"class");

/**
 *  目标视图控制器是UIViewController，但其视图是通过nib来加载的。
 *
 *  @see +targetWithURLString:
 */
QP_STATIC_STRING(QPLinkerSchemeNib, @"nib");


/**
 *  用于判断视图控制器的storyboard属性是否被锁定的关联对象的键名。当视图控制器的
 *  storyboard属性被锁定后，属性值只能从nil修改为一个有效值，但不能从一个有效值
 *  修改为另一个有效值。这样可以避免从一个storyboard跳转到另一个storyboard时，跳
 *  入后的视图控制器的storyboard属性被修改为跳入前的storyboard实例，继而导致跳入
 *  后的视图控制器在加载视图时，试图从跳入前的storyboard加载，从而导致加载失败。
 */
QP_STATIC_KEYNAME(QPIsStoryboardLocked);


#pragma mark - 锁定storyboard属性。

@interface UIViewController (Linker)

@end

@implementation UIViewController (Linker)

- (void)setValue:(id)value forKey:(NSString *)key
{
    BOOL modifiable = YES;

    if ([key isEqualToString:@"storyboard"] && [self valueForKey:key]) {
        modifiable = ![[self associatedValueForKey:QPIsStoryboardLocked] boolValue];
    }

    if (modifiable) {
        [super setValue:value forKey:key];
    }
}

@end


#pragma mark - 支持NSString=>BOOL转换。

@interface NSString (Boolean)

@end

@implementation NSString (Boolean)

- (char)charValue
{
    // 由于@encode(char)与@encode(BOOL)相等，所以在使用-setValue:forKey:为对象的
    // BOOL类型属性设置NSString类型的布尔值时（例如@"YES"），系统是调用NSString
    // 类型所没有的-charValue方法转换为布尔值的，而不是使用NSString类型本身已经
    // 支持的-boolValue方法。所以这里添加-charValue方法，并回调到-boolValue方法。

    return [self boolValue];
}

@end

#pragma mark - 支持在低于iOS 8.0的设备使用QPLinker。

@interface UIStoryboardSegue (QPLinker)

@end

@implementation UIStoryboardSegue (QPLinker)

+ (void)initialize
{
    // 由于在低于iOS 8.0的设备上使用QPLinker跳转到另一个storyboard时，一般不会再
    // 在跳入的storyboard中添加一个新的导航控制器。所以在这个storyboard上的Segue
    // 如果使用Show行为来推视图控制器的话，会被认为是Present，而不是Push。所以这
    // 里需要重新实现一下UIStoryboardSegue的默认处理函数，如果可以Push应尽量使用
    // Push行为进行处理。

    if ([self class] == NSClassFromString(@"UIStoryboardModalSegue")) {
        [self swizzleSelector:@selector(perform)
                   toSelector:@selector(performForQPLinker)];
    }
}

- (void)performForQPLinker
{
    UINavigationController *navigationController = [self.sourceViewController
                                                    navigationController];
    if (navigationController) {
        [navigationController pushViewController:self.destinationViewController
                                        animated:YES];
    }
    else {
        [self performForQPLinker];  // Calling `-perform' in fact.
    }
}

@end


#pragma mark - 链接目标视图控制器。

@implementation QPLinker

#pragma mark - 解释目标视图控制器。

+ (NSURL *)targetURLWithURLString:(NSString *)URLString
{
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:
                 [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *URL = [NSURL URLWithString:URLString];

    // 从URL中提取目标视图控制的相关参数。

    NSString *scheme = [[URL scheme] lowercaseString];
    NSString *host = [URL host];
    NSString *position = nil;
    NSString *query = [URL query];

    if ([[URL pathComponents] count] > 0) {
        position = [[URL pathComponents] lastObject];
    }

    // 如果没有对象名称，则直接返回nil。

    if ([host length] <= 0) {
        return nil;
    }

    // 将view-controller协议简写成class协议。

    if ([scheme isEqualToString:QPLinkerSchemeViewController]) {
        scheme = QPLinkerSchemeClass;
    }

    // 将nib协议转换成class协议。

    if ([scheme isEqualToString:QPLinkerSchemeNib]) {
        scheme = QPLinkerSchemeClass;
        position = host;
        host = NSStringFromClass([UIViewController class]);
    }

    // 如果是不支持的链接协议，则直接返回nil。

    if (![scheme isEqualToString:QPLinkerSchemeStoryboard] &&
        ![scheme isEqualToString:QPLinkerSchemeClass]) {
        return nil;
    }

    // 构建标准化后的目标对象URL并返回。

    NSMutableString *targetURLString = [NSMutableString string];

    [targetURLString appendFormat:@"%@://%@", scheme, host];

    if ([position length] > 0) {
        [targetURLString appendFormat:@"/%@", position];
    }

    if ([query length] > 0) {
        [targetURLString appendFormat:@"?%@", query];
    }

    return [NSURL URLWithString:targetURLString];
}

#pragma mark - 创建目标视图控制器。

+ (id)targetWithURLString:(NSString *)URLString
{
    return [self targetWithTargetURL:[self targetURLWithURLString:URLString]];
}

+ (id)targetWithTargetURL:(NSURL *)targetURL
{
    UIViewController *viewController = nil;

    if (!targetURL) {
        return nil;
    }

    NSString *scheme = [targetURL.scheme stringByRemovingPercentEncoding];
    NSString *host = [targetURL.host stringByRemovingPercentEncoding];
    NSString *lastPathComponent = [targetURL.lastPathComponent stringByRemovingPercentEncoding];
    NSString *query = [targetURL.query stringByRemovingPercentEncoding];

    // 如果目标对象是视图控制器类名称，则直接创建该视图控制器类的实例。

    if ([scheme isEqualToString:QPLinkerSchemeClass]) {
        if ([lastPathComponent length] > 0) {
            viewController = [(UIViewController *)
                              [NSClassFromString(host) alloc]
                              initWithNibName:lastPathComponent
                              bundle:nil];
        }
        else {
            viewController = [[NSClassFromString(host) alloc] init];
        }
    }

    // 如果目标对象是storyboard名称，则从storyboard中加载该视图控制器实例。

    if ([scheme isEqualToString:QPLinkerSchemeStoryboard]) {
        UIStoryboard *storyboard = [UIStoryboard
                                    storyboardWithName:host
                                    bundle:nil];
        if ([lastPathComponent length] > 0) {
            viewController = [storyboard
                              instantiateViewControllerWithIdentifier:
                              lastPathComponent];
        }
        else {
            viewController = [storyboard instantiateInitialViewController];
        }
    }

    // 如果地址中含有属性设置项，则将这些属性设置到新创建的视图控制器实例。

    if (viewController && [query length] > 0) {
        NSCharacterSet *spaces = [NSCharacterSet
                                  whitespaceAndNewlineCharacterSet];
        NSArray *kvs = [query componentsSeparatedByString:@"&"];
        for (NSString *kv in kvs) {
            NSArray *arguments = [kv componentsSeparatedByString:@"="];
            if (2 == [arguments count]) {
                NSString *key = [[arguments objectAtIndex:0]
                                 stringByTrimmingCharactersInSet:spaces];
                NSString *value = [[arguments objectAtIndex:1]
                                   stringByTrimmingCharactersInSet:spaces];
                if ([key length] > 0) {
                    [viewController setValue:value forKeyPath:key];
                }
            }
        }
    }

    return viewController;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    UIViewController *viewController = nil;

    // 解释目标视图控制器的地址并创建其对象实例。

    NSURL *targetURL = [[self class] targetURLWithURLString:self.title];
    viewController = [[self class] targetWithTargetURL:targetURL];

    if ([targetURL.scheme isEqualToString:QPLinkerSchemeStoryboard]) {
        [viewController setAssociatedValue:@(YES) forKey:QPIsStoryboardLocked];
    }

    // 如果没有设置title属性或设置不正确，则报错返回。

    if (!viewController) {
        [NSException raise:@"QPLinkerException" format:
         @"[QPFoundation] QPLinker's title [%@] isn't a valid target url.",
         self.title];
    }

    // 将在storyboard中给QPLinker设置的属性复制到新创建的视图控制器上。
    // 暂时只支持对tabBarItem属性的复制，其它属性应该在目标视图控制器上进行设置。

    if ([viewController.tabBarItem.title length] <= 0
        && !viewController.tabBarItem.image) {
        [viewController.tabBarItem assignCopy:self.tabBarItem];
    }

    // 在storyboard中将QPLinker作为UINavigationController的root-view-controller
    // 或者作为UITabBarController的view-controllers中的一员时，视图控制器的父子
    // 结构在调用initWithCoder完成后即已经进行设置，所以导致链接到新的视图控制器
    // 时，其navigationController及tabBarController属性为空。为解决该问题，需要
    // 在这里重新建立链接后的视图控制器与父视图控制器的父子关系。

    if ([self.parentViewController respondsToSelector:@selector(setViewControllers:)]) {
        __weak id parentViewController = self.parentViewController;
        __weak UIViewController *childViewController = viewController;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *viewControllers = [parentViewController viewControllers];
            if (childViewController && [viewControllers containsObject:childViewController]) {
                [parentViewController addChildViewController:childViewController];
                [parentViewController setViewControllers:viewControllers];
            }
        });
    }

    return viewController;
}

@end
