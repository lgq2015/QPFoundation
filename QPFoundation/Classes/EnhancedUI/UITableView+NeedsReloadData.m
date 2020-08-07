//
//  UITableView+NeedsReloadData.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/16.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UITableView+NeedsReloadData.h>
#import <QPFoundation/QPSetNeedsWithBlock.h>
#import <QPFoundation/NSObject+Association.h>


QP_STATIC_KEYNAME(QPTableViewNeedsReloadDataIndexPathsKey);


@implementation UITableView (NeedsReloadData)

- (void)setNeedsReloadData
{
    QPSetNeedsWithBlock(^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    });
}

- (void)setNeedsReloadDataWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableSet *needsReloadDataIndexPaths;

    needsReloadDataIndexPaths = [self associatedValueForKey:
                                 QPTableViewNeedsReloadDataIndexPathsKey];
    if (!needsReloadDataIndexPaths) {
        needsReloadDataIndexPaths = [[NSMutableSet alloc] init];
        [self setAssociatedValue:needsReloadDataIndexPaths
                          forKey:QPTableViewNeedsReloadDataIndexPathsKey];
    }

    [needsReloadDataIndexPaths addObject:indexPath];

    QPSetNeedsWithBlock(^{
        NSArray *indexPaths = [needsReloadDataIndexPaths allObjects];
        [needsReloadDataIndexPaths removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *reloadIndexPaths = [[NSMutableArray alloc] init];
            NSUInteger numberOfSections = [self numberOfSections];
            NSUInteger numberOfRows = 0;

            for (NSIndexPath *indexPath in indexPaths) {
                if (indexPath.section < 0 ||
                    indexPath.section >= numberOfSections) {
                    continue;
                }

                numberOfRows = [self numberOfRowsInSection:indexPath.section];
                if (indexPath.row < 0 ||
                    indexPath.row >= numberOfRows) {
                    continue;
                }

                [reloadIndexPaths addObject:indexPath];
            }

            if ([reloadIndexPaths count] > 0) {
                [self reloadRowsAtIndexPaths:reloadIndexPaths
                            withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    });
}

@end
