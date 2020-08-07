//
//  QPBaseViewController.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/20.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

/**
 *  所有框架定义的页面视图控制器及其子类的根类，默认什么也都不提供，但框架使用者
 *  可以通过类别及关联对象的方式对其进行扩展，从而实现一些所有页面所共有的功能。
 *  特别是可以实现子类QPPanelController、QPScrollPanelController等的非正式协议，
 *  从而在子类发生特定事件时，进行一些定制化的处理。
 */
@interface QPBaseViewController : UIViewController

@end
