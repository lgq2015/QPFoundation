//
//  QPCustomBar.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/7.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPApplicationFrameworkObject.h>

@interface QPCustomBar : UIView<QPApplicationFrameworkObject>

/**
 *  创建QPCustomBar实例，并包裹自定义视图。包裹时会拉伸并居中该视图。
 */
+ (instancetype)customBarWithView:(UIView *)view;

@end
