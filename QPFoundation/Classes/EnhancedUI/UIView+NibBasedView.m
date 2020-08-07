//
//  UIView+NibBasedView.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 14-12-1.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIView+NibBasedView.h>
#import <objc/runtime.h>

@implementation UIView (NibBasedView)

// 返回当前视图绑定的Nib文件的名称，默认与类名相同。
+ (NSString *)nameOfBindingNib
{
    return NSStringFromClass([self class]);
}

// 加载Nib文件，并返回主视图实例。
+ (instancetype)viewWithNib
{
    NSString *nibName = [self nameOfBindingNib];
    id mainView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                 owner:nil
                                               options:nil] lastObject];

    if (![mainView isKindOfClass:[self class]]) {
        NSLog(@"[QPFoundation] warning: The main view of [%@.xib] that it's not a kind of class [%@].",
              nibName, NSStringFromClass([self class]));
        return nil;
    }

    return mainView;
}

// 加载Nib文件，返回将指定索引的视图实例。
+ (instancetype)viewWithNibByIndex:(NSUInteger)index
{
    NSString *nibName = [self nameOfBindingNib];
    id mainView = [[[NSBundle mainBundle] loadNibNamed:nibName
                                                 owner:nil
                                               options:nil] objectAtIndex:index];

    if (![mainView isKindOfClass:[self class]]) {
        NSLog(@"[QPFoundation] warning: The main view of [%@.xib] that it's not a kind of class [%@].",
              nibName, NSStringFromClass([self class]));
        return nil;
    }

    return mainView;
}

// 加载Nib文件，并将当前视图的位置、外观等相关属性复制到新视图。
- (instancetype)reloadWithNib
{
    // 加载堆栈，每次调用时检测是否有嵌套循环，如果没有则在堆顶压入当前类名。
    // 检测堆栈里面是否已存在当前类名，如果存在则表示产生嵌套循环了，不允许进行加载。
    // 由于加载NIB等界面相关动作一般都是在主线程进行，这里暂不考虑多线程问题。

    static NSMutableArray *reloadStack = nil;

    // 如果当前视图存在子视图，则表示其不是占位用的视图，直接返回self。

    if ([[self subviews] count] >= 1) {
        return self;
    }

    // 仅支持在主线程上调用该方法。

    NSString *currentClassName = NSStringFromClass([self class]);
    if (![[NSThread currentThread] isMainThread]) {
        NSLog(@"[QPFoundation] warning: The current thread that reloading NibBasedView:[%@] isn't the main thread.", currentClassName);
        return self;
    }

    if (!reloadStack) {
        reloadStack = [[NSMutableArray alloc] init];
    }

    // 校验加载当前Nib后是否会出现重载循环，如果会，则不再重载，直接返回self。

    for (NSString *className in reloadStack) {
        if ([className isEqualToString:currentClassName]) {
            return self;
        };
    }

    // 向重载堆栈压入当前类名。

    [reloadStack addObject:currentClassName];

    // 重载Nib，重载期间将当前类的awakeFromNib指向UIView的awakeFromNib，避免实例的该方法重复调用。

    Method selfMethod = class_getInstanceMethod([self class], @selector(awakeFromNib));
    Method viewMethod = class_getInstanceMethod([UIView class], @selector(awakeFromNib));
    IMP selfImplementation = method_getImplementation(selfMethod);
    IMP viewImplementation = method_getImplementation(viewMethod);

    if (selfImplementation != viewImplementation) {
        method_setImplementation(selfMethod, viewImplementation);
    }

    UIView *instance = [[self class] viewWithNib];

    if (selfImplementation != viewImplementation) {
        method_setImplementation(selfMethod, selfImplementation);
    }

    if (!instance) {
        assert(currentClassName == reloadStack.lastObject);
        [reloadStack removeLastObject];
        return self;
    }

    // 复制位置相关属性。

    instance.frame = self.frame;
    instance.autoresizingMask = self.autoresizingMask;
    instance.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints;

    // 复制视图与其它对象无关联的约束（例如：宽、高）。

    for (NSLayoutConstraint *constraint in [self constraints]) {
        if (self == constraint.firstItem && !constraint.secondItem) {
            [instance addConstraint:[NSLayoutConstraint constraintWithItem:instance
                                                                 attribute:constraint.firstAttribute
                                                                 relatedBy:constraint.relation
                                                                    toItem:constraint.secondItem
                                                                 attribute:constraint.secondAttribute
                                                                multiplier:constraint.multiplier
                                                                  constant:constraint.constant]];
        }
    }

    // 复制外观相关的属性。

    instance.clipsToBounds = self.clipsToBounds;
    instance.hidden = self.hidden;

    if (fabs(1 - instance.alpha) < 0.0000001) {
        instance.alpha = self.alpha;
    }

    if (!instance.clipsToBounds) {
        instance.clipsToBounds = self.clipsToBounds;
    }

    // 复制标识相关的属性。

    if (0 == instance.tag) {
        instance.tag = self.tag;
    }

    if (0 == instance.restorationIdentifier.length) {
        instance.restorationIdentifier = self.restorationIdentifier;
    }

    // 复制行为相关的属性。

    if (instance.userInteractionEnabled) {
        instance.userInteractionEnabled = self.userInteractionEnabled;
    }

    if (!instance.multipleTouchEnabled) {
        instance.multipleTouchEnabled = self.multipleTouchEnabled;
    }

    // 将当前类名从重载堆栈中移除。

    assert(currentClassName == reloadStack.lastObject);
    [reloadStack removeLastObject];

    return instance;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    // 忽略对UI开头的系统定义的视图进行处理。如UILabel、UITableView等。

    NSString *nibName = [[self class] nameOfBindingNib];
    if (NSOrderedSame == [nibName compare:@"UI" options:0 range:NSMakeRange(0, 2)]) {
        return self;
    }

    // 判断当前视图绑定的nib文件是否存在。

    NSString *nibPath = [[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"];
    if ([nibPath length] <= 0) {
        nibPath = [[NSBundle mainBundle] pathForResource:nibName ofType:@"xib"];
        if ([nibPath length] <= 0) {
            return self;
        }
    }

    // 重加载nib文件，并替换当前视图。

    UIView *nibView = [self reloadWithNib];

    // convince ARC that we're legit, unnecessary since at least Xcode 4.5

    // CFRetain((__bridge const void*)nibView);
    // CFRelease((__bridge const void*)self);

    return nibView;
}

@end


@implementation UITableViewCell (NibBasedCell)

// 返回当前Cell的重用符，默认与Nib名称相同。
+ (NSString *)identifierOfBindingNib
{
    return [self nameOfBindingNib];
}

// 为指定的tableView加载Nib并返回当前类的Cell实例，并且支持Cell实例的重用。
+ (instancetype)cellWithNibForTableView:(UITableView *)tableView
{
    // 使用Cell的nib名称（默认取其类名）作为重用标识符。

    NSString *identifier = [self identifierOfBindingNib];
    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    // 如果tableView未注册重用该Cell，则注册后再进行获取。

    if (!cell) {
        NSString *nibName = [self nameOfBindingNib];
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }

    // 如果仍未能加载到该Cell，则直接手动加载，但应注意这样做很消耗内存。

    if (!cell) {
        cell = [self viewWithNib];
    }

    return cell;
}

@end
