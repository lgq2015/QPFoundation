//
//  UIView+NibBasedView.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 14-12-1.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIView (NibBasedView)

/**
 *  返回当前视图绑定的Nib文件的名称，默认与类名相同。
 *
 *  @return 返回当前视图绑定的Nib文件的名称，默认与类名相同。
 */
+ (NSString *)nameOfBindingNib;

/**
 *  加载Nib文件，并返回主视图实例。
 *
 *  @return 返回新加载的主视图实例。
 *
 *  @note 默认Nib文件名和类名一致，否则需要重写`bindingNibName`方法。
 */
+ (instancetype)viewWithNib;

/**
 *  加载Nib文件，返回将指定索引的视图实例。
 *
 *  @param index 索引。
 *
 *  @return 返回新加载的主视图实例。
 *
 *  @note 默认Nib文件名和类名一致，否则需要重写`bindingNibName`方法。
 */
+ (instancetype)viewWithNibByIndex:(NSUInteger)index;

@end

@interface UITableViewCell (NibBasedCell)

/**
 *  返回当前Cell的重用符，默认与Nib名称相同。
 *
 *  @return 返回当前Cell的重用符，默认与Nib名称相同。
 */
+ (NSString *)identifierOfBindingNib;

/**
 *  为指定的tableView加载Nib并返回当前类的Cell实例对象，并且支持Cell的重用。
 *
 *  @param tableView 表格实例。
 *
 *  @return 返回当前类的Cell实例对象。
 */
+ (instancetype)cellWithNibForTableView:(UITableView *)tableView;

@end
