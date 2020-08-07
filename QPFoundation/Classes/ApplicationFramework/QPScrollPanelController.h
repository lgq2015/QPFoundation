//
//  QPScrollPanelController.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/7.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>
#import <QPFoundation/QPPanelController.h>

@interface QPScrollPanelController : QPPanelController

/**
 *  滚动视图，即wrapperView。主要起到可以上下滚动浏览内容较长的内容视图。
 *
 *  @see -[QPPanelController wrapperView]
 */
@property (nonatomic, readonly) UIScrollView *scrollView;

@end

/**
 *  与QPScrollPanelController相关的非正式协议，框架使用者可以在
 *  QPScrollPanelController的子类或父类QPBaseViewController的类别中实现这些方法，
 *  从而在特定事件发生时可以进行一些定制化的处理。
 */
@interface NSObject (QPScrollPanelController)

/**
 *  当QPScrollPanelController的包装视图scrollView的contentSize由于布局更新而发生
 *  变化前，回调该方法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)wrapperScrollView:(UIScrollView *)scrollView
willChangeContentSizeFrom:(CGSize)fromContentSize
                       to:(CGSize)toContentSize;

/**
 *  当QPScrollPanelController的包装视图scrollView的contentSize由于布局更新而发生
 *  变化后，回调该方法。子类或父类（的类别）可以实现该方法进行定制化处理。
 */
- (void)wrapperScrollView:(UIScrollView *)scrollView
 didChangeContentSizeFrom:(CGSize)fromContentSize
                       to:(CGSize)toContentSize;

@end