//
//  UINavigationItem+Assignment.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/17.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UINavigationItem+Assignment.h>

@implementation UINavigationItem (Assignment)

- (void)assignCopy:(UINavigationItem *)other
{
    self.title = other.title;
    self.prompt = other.prompt;
    self.backBarButtonItem = other.backBarButtonItem;
    self.hidesBackButton = other.hidesBackButton;
    self.leftItemsSupplementBackButton = other.leftItemsSupplementBackButton;

    self.titleView = other.titleView;
    self.leftBarButtonItem = other.leftBarButtonItem;
    self.leftBarButtonItems = other.leftBarButtonItems;
    self.rightBarButtonItem = other.rightBarButtonItem;
    self.rightBarButtonItems = other.rightBarButtonItems;
}

@end
