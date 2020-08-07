//
//  QPLinker.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/15.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface QPLinker : UIViewController

/**
 *  创建URL地址指向的目标视图控制器的对象。
 *
 *  @param URLString  URL地址，支持storyboard、view-controller、class、nib协议。
 *
 *  @note 各种目标视图控制器的URL地址的写法如下：
 *            storyboard://<storyboard-name>[/<scene-storyboard-id>]
 *            view-controller://<view-controller-class-name>[/<nib-name>]
 *            class://<view-controller-class-name>[/<nib-name>]
 *            nib://<nib-name>
 *
 *        除此之外，还可以在URL地址的后面附带若干属性设置项，QPLinker会将这些属
 *        性设置项通过-setValue:forKeyPath:的方式设置到新创建的目标视图控制器对
 *        象上，属性设置的格式如下：
 *            [?keyPath1=value1[&keyPath2=value2]...]
 *
 *        下面是一些目标视图控制器的URL地址的例子：
 *             storyboard://Main
 *             storyboard://Main/SecondViewController
 *             class://CustomerViewController?isFromChangeProduct=YES
 *             class://CustomerViewController/CustomerView
 *             nib://CustomerView
 *
 *  @return 返回创建的目标视图控制器对象，如果URL地址无效，则返回nil。
 */
+ (id)targetWithURLString:(NSString *)URLString;

@end
