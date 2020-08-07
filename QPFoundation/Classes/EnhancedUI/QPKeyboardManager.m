//
//  QPKeyboardManager.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/17.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPKeyboardManager.h>
#import <QPFoundation/QPApplicationFramework.h>


/**
 *  挂在keyWindow上的全屏结束编辑视图的关联键名。
 */
QP_STATIC_KEYNAME(QPFullScreenEndEditingView);


#pragma mark - 全屏结束编辑视图。

@interface QPEndEditingView : UIView

@end

@implementation QPEndEditingView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // 如果当前在递归调用的过种中，则直接返回NO。

    QP_STATIC_KEYNAME(QPKeyboardManagerIsLockedPointInside);
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    BOOL isLockedPointInside = [[threadDictionary objectForKey:
                                 QPKeyboardManagerIsLockedPointInside] boolValue];
    if (isLockedPointInside) {
        return NO;
    }

    // 判断点所在位置是否是当前正在输入的文本框。

    id firstResponder = QPGetFirstResponder();
    if ([firstResponder isKindOfClass:[UIView class]]) {
        UIView *inputView = (UIView *)firstResponder;
        CGRect bounds = [inputView bounds];
        CGPoint touchPoint = [self convertPoint:point toView:inputView];
        if (CGRectContainsPoint(bounds, touchPoint)) {
            return NO;
        }
    }

    // 判断点所在位置是否是其它未被激活的文本框。

    [threadDictionary setValue:@(YES) forKey:QPKeyboardManagerIsLockedPointInside];
    UIView *superview = [self superview];
    CGPoint superPoint = [self convertPoint:point toView:superview];
    UIView *hitTestView = [superview hitTest:superPoint withEvent:event];
    [threadDictionary setValue:@(NO) forKey:QPKeyboardManagerIsLockedPointInside];

    if ([hitTestView isKindOfClass:[UITextField class]] ||
        [hitTestView isKindOfClass:[UITextView class]]) {
        return NO;
    }

    return [super pointInside:point withEvent:event];
}

@end


#pragma mark - 键盘管理器。

@implementation QPKeyboardManager

#pragma mark - 公共方法。

+ (void)load
{
    [self sharedInstance];
}

+ (instancetype)sharedInstance
{
    static QPKeyboardManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - 初始化及销毁。

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        [center addObserver:self
                   selector:@selector(keyboardWillShow:)
                       name:UITextFieldTextDidBeginEditingNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(keyboardDidHide:)
                       name:UITextFieldTextDidEndEditingNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(keyboardWillShow:)
                       name:UITextViewTextDidBeginEditingNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(keyboardDidHide:)
                       name:UITextViewTextDidEndEditingNotification
                     object:nil];
    }
    return self;
}

#pragma mark - 全局消息响应。

- (void)keyboardWillShow:(id)sender
{
    // 如果原来已经有全屏结束编辑视图（虽然这是不可能的），则先将其从屏幕上删除。

    UIWindow *window = QPGetKeyWindow();
    QPEndEditingView *endEditingView;
    endEditingView = [window associatedValueForKey:QPFullScreenEndEditingView];
    [endEditingView removeFromSuperview];
    [window setAssociatedValue:nil forKey:QPFullScreenEndEditingView];

    // 添加全屏结束编辑视图。

    endEditingView = [[QPEndEditingView alloc] initWithFrame:[window bounds]];
    [window addSubview:endEditingView];
    [window setAssociatedValue:endEditingView
                        forKey:QPFullScreenEndEditingView
         withAssociationPolicy:QPAssociationPolicyWeak];

    // 为全屏结束编辑视图添加点击事件。

    UITapGestureRecognizer *tap;
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(onEndEditingViewClick:)];
    [endEditingView addGestureRecognizer:tap];
}

- (void)keyboardDidHide:(id)sender
{
    UIWindow *window = QPGetKeyWindow();
    QPEndEditingView *endEditingView;
    endEditingView = [window associatedValueForKey:QPFullScreenEndEditingView];
    [endEditingView removeFromSuperview];
    [window setAssociatedValue:nil forKey:QPFullScreenEndEditingView];
}

- (void)onEndEditingViewClick:(id)sender
{
    [QPGetKeyWindow() endEditing:YES];
}

@end
