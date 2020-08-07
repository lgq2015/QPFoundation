//
//  QPFoundationPreferences.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/11/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


#pragma mark - 框架相关参数

// 是否启用页面导航控制器，默认启用。
FOUNDATION_EXPORT BOOL QPFoundationIsEnablePageNavigationController;

// 是否启用页面切换控制器，默认不启用。
FOUNDATION_EXPORT BOOL QPFoundationIsEnableTabBarController;

// 是否启用页面切换控制器中每个TabBarItem都使用导航控制器进行包装，默认不启用。
FOUNDATION_EXPORT BOOL QPFoundationIsEnableNavigationControllerPerTabBarItem;

// 是否启用页面切换控制器切换页面的同时将导航项切换为页面的导航项，默认启用。
FOUNDATION_EXPORT BOOL QPFoundationIsEnableTabBarControllerSwitchNavigationItem;

// 是否预先将页面导航控制器/页面切换控制器推至全屏，默认为是。
FOUNDATION_EXPORT BOOL QPFoundationIsPrepushingFrameworkController;


#pragma mark - 导航栏相关参数

// 导航栏背景色，默认为天蓝色（0x2196f3）。
FOUNDATION_EXPORT NSUInteger QPFoundationNavigationBarBackgroundColor;

// 导航栏背景图片，使用图片中心1x1进行拉伸。默认没有背景图片。
FOUNDATION_EXPORT NSString *QPFoundationNavigationBarBackgroundImageName;

// 导航栏背景图片，支持用户定制的拉伸方式。默认没有背景图片。
FOUNDATION_EXPORT UIImage *QPFoundationNavigationBarBackgroundImage;

// 导航栏字体颜色，默认为白色（0xffffff）。
FOUNDATION_EXPORT NSUInteger QPFoundationNavigationBarTextColor;

// 导航栏返回指示图片，使用原图不进行拉伸。默认使用导航栏控件原生图片。
FOUNDATION_EXPORT NSString *QPFoundationNavigationBarBackIndicatorImageName;

// 导航栏返回指示图片，支持用户定制的拉伸方式。默认使用导航栏控件原生图片。
FOUNDATION_EXPORT UIImage *QPFoundationNavigationBarBackIndicatorImage;

// 导航栏底部分隔线是否显示，默认显示底部分隔线。
FOUNDATION_EXPORT BOOL QPFoundationNavigationBarShowsBottomSeparationLine;


#pragma mark - 工具栏相关参数

// 工具栏背景色，默认亮灰色（0xeeeeee）。
FOUNDATION_EXPORT NSUInteger QPFoundationToolbarBackgroundColor;

// 工具栏背景图片，使用图片中心1x1进行拉伸。默认没有背景图片。
FOUNDATION_EXPORT NSString *QPFoundationToolbarBackgroundImageName;

// 工具栏背景图片，支持用户定制的拉伸方式。默认没有背景图片。
FOUNDATION_EXPORT UIImage *QPFoundationToolbarBackgroundImage;

// 工具栏字体颜色，默认为亮蓝色（0x2196f3）。
FOUNDATION_EXPORT NSUInteger QPFoundationToolbarTextColor;


#pragma mark - Tab栏相关参数

// Tab栏背景色，默认亮灰色（0xeeeeee）。
FOUNDATION_EXPORT NSUInteger QPFoundationTabBarBackgroundColor;

// Tab栏背景图片，使用图片中心1x1进行拉伸。默认没有背景图片。
FOUNDATION_EXPORT NSString *QPFoundationTabBarBackgroundImageName;

// Tab栏背景图片，支持用户定制的拉伸方式。默认没有背景图片。
FOUNDATION_EXPORT UIImage *QPFoundationTabBarBackgroundImage;

// Tab栏阴影图片，使用图片中心1x1进行拉伸。默认没有阴影图片。
FOUNDATION_EXPORT NSString *QPFoundationTabBarShadowImageName;

// Tab栏阴影图片，支持用户定制的拉伸方式。默认没有阴影图片。
FOUNDATION_EXPORT UIImage *QPFoundationTabBarShadowImage;

// Tab栏字体颜色，默认为亮蓝色（0x2196f3）。
FOUNDATION_EXPORT NSUInteger QPFoundationTabBarTextColor;

// Tab栏选中指示图片，使用原图不进行拉伸。默认使用Tab栏控件原生图片。
FOUNDATION_EXPORT NSString *QPFoundationTabBarSelectionIndicatorImageName;

// Tab栏选中指示图片，支持用户定制的拉伸方式。默认使用Tab栏控件原生图片。
FOUNDATION_EXPORT UIImage *QPFoundationTabBarSelectionIndicatorImage;

// Tab栏顶部分隔线是否显示，默认显示顶部分隔线。
FOUNDATION_EXPORT BOOL QPFoundationTabBarShowsTopSeparationLine;


#pragma mark - 定制栏相关参数

// 定制栏最小高度，默认为44。
FOUNDATION_EXPORT CGFloat QPFoundationCustomBarMinimumHeight;

// 定制栏背景色，默认为天蓝色（0x2196f3）。
FOUNDATION_EXPORT NSUInteger QPFoundationCustomBarBackgroundColor;


#pragma mark - 页面相关参数

// 页面背景色，默认为白色（0xffffff）。
FOUNDATION_EXPORT NSUInteger QPFoundationPanelBackgroundColor;

// 页面内容视图的背景色是否透明，默认为透明。
FOUNDATION_EXPORT BOOL QPFoundationPanelContentViewTransparent;
