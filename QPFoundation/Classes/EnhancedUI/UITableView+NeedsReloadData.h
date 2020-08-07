//
//  UITableView+NeedsReloadData.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/16.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UITableView (NeedsReloadData)

- (void)setNeedsReloadData;
- (void)setNeedsReloadDataWithIndexPath:(NSIndexPath *)indexPath;

@end
