//
//  QPFoundationPreferences.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPFoundationPreferences.h>


#pragma mark - 框架相关参数

// 是否启用页面导航控制器，默认启用。
BOOL QPFoundationIsEnablePageNavigationController = YES;

// 是否启用页面切换控制器，默认不启用。
BOOL QPFoundationIsEnableTabBarController = NO;

// 是否启用页面切换控制器中每个TabBarItem都使用导航控制器进行包装，默认不启用。
BOOL QPFoundationIsEnableNavigationControllerPerTabBarItem = NO;

// 是否启用页面切换控制器切换页面的同时将导航项切换为页面的导航项，默认启用。
BOOL QPFoundationIsEnableTabBarControllerSwitchNavigationItem = YES;

// 是否预先将页面导航控制器/页面切换控制器推至全屏，默认为是。
BOOL QPFoundationIsPrepushingFrameworkController = YES;


#pragma mark - 导航栏相关参数

// 导航栏背景色，默认为天蓝色（0x2196f3）。
NSUInteger QPFoundationNavigationBarBackgroundColor = 0x2196f3;

// 导航栏背景图片，使用图片中心1x1进行拉伸。默认没有背景图片。
NSString *QPFoundationNavigationBarBackgroundImageName = nil;

// 导航栏背景图片，支持用户定制的拉伸方式。默认没有背景图片。
UIImage *QPFoundationNavigationBarBackgroundImage = nil;

// 导航栏字体颜色，默认为白色（0xffffff）。
NSUInteger QPFoundationNavigationBarTextColor = 0xffffff;

// 导航栏返回指示图片，使用原图不进行拉伸。默认使用导航栏控件原生图片。
NSString *QPFoundationNavigationBarBackIndicatorImageName = nil;

// 导航栏返回指示图片，支持用户定制的拉伸方式。默认使用导航栏控件原生图片。
UIImage *QPFoundationNavigationBarBackIndicatorImage = nil;

// 导航栏底部分隔线是否显示，默认显示底部分隔线。
BOOL QPFoundationNavigationBarShowsBottomSeparationLine = YES;


#pragma mark - 工具栏相关参数

// 工具栏背景色，默认亮灰色（0xeeeeee）。
NSUInteger QPFoundationToolbarBackgroundColor = 0xeeeeee;

// 工具栏背景图片，使用图片中心1x1进行拉伸。默认没有背景图片。
NSString *QPFoundationToolbarBackgroundImageName = nil;

// 工具栏背景图片，支持用户定制的拉伸方式。默认没有背景图片。
UIImage *QPFoundationToolbarBackgroundImage = nil;

// 工具栏字体颜色，默认为亮蓝色（0x2196f3）。
NSUInteger QPFoundationToolbarTextColor = 0x2196f3;


#pragma mark - Tab栏相关参数

// Tab栏背景色，默认亮灰色（0xeeeeee）。
NSUInteger QPFoundationTabBarBackgroundColor = 0xeeeeee;

// Tab栏背景图片，使用图片中心1x1进行拉伸。默认没有背景图片。
NSString *QPFoundationTabBarBackgroundImageName = nil;

// Tab栏背景图片，支持用户定制的拉伸方式。默认没有背景图片。
UIImage *QPFoundationTabBarBackgroundImage = nil;

// Tab栏阴影图片，使用图片中心1x1进行拉伸。默认没有阴影图片。
NSString *QPFoundationTabBarShadowImageName = nil;

// Tab栏阴影图片，支持用户定制的拉伸方式。默认没有阴影图片。
UIImage *QPFoundationTabBarShadowImage = nil;

// Tab栏字体颜色，默认为亮蓝色（0x2196f3）。
NSUInteger QPFoundationTabBarTextColor = 0x2196f3;

// Tab栏选中指示图片，使用原图不进行拉伸。默认使用Tab栏控件原生图片。
NSString *QPFoundationTabBarSelectionIndicatorImageName = nil;

// Tab栏选中指示图片，支持用户定制的拉伸方式。默认使用Tab栏控件原生图片。
UIImage *QPFoundationTabBarSelectionIndicatorImage = nil;

// Tab栏顶部分隔线是否显示，默认显示顶部分隔线。
BOOL QPFoundationTabBarShowsTopSeparationLine = YES;


#pragma mark - 定制栏相关参数

// 定制栏最小高度，默认为44。
CGFloat QPFoundationCustomBarMinimumHeight = 44.0;

// 定制栏背景色，默认为天蓝色（0x2196f3）。
NSUInteger QPFoundationCustomBarBackgroundColor = 0x2196f3;


#pragma mark - 页面相关参数

// 页面背景色，默认为白色（0xffffff）。
NSUInteger QPFoundationPanelBackgroundColor = 0xffffff;

// 页面内容视图的背景色是否透明，默认为透明。
BOOL QPFoundationPanelContentViewTransparent = YES;
