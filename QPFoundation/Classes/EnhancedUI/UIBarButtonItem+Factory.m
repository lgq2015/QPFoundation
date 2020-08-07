//
//  UIBarButtonItem+Factory.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/17.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIBarButtonItem+Factory.h>

@implementation UIBarButtonItem (Factory)

+ (instancetype)itemWithTitle:(NSString *)title
                       target:(id)target
                       action:(SEL)action
{
    UIBarButtonItem *item = nil;

    item = [[UIBarButtonItem alloc] initWithTitle:title
                                            style:UIBarButtonItemStylePlain
                                           target:target
                                           action:action];

    return item;
}

+ (instancetype)itemWithImage:(NSString *)imageName
{
    UIBarButtonItem *item = nil;

    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    item = [[UIBarButtonItem alloc] initWithCustomView:imageView];

    return item;
}

+ (instancetype)itemWithImage:(NSString *)imageName
                       target:(id)target
                       action:(SEL)action
{
    UIBarButtonItem *item = nil;

    UIImage *image = [UIImage imageNamed:imageName];

    item = [[UIBarButtonItem alloc] initWithImage:image
                                            style:UIBarButtonItemStyleDone
                                           target:target
                                           action:action];

    return item;
}

+ (instancetype)itemWithImage:(NSString *)imageName
             highlightedImage:(NSString *)highlightedImageName
                       target:(id)target
                       action:(SEL)action
{
    UIBarButtonItem *item = nil;

    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *highlightedImage = [UIImage imageNamed:highlightedImageName];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button setContentMode:UIViewContentModeCenter];

    [button addTarget:target
               action:action
     forControlEvents:UIControlEventTouchUpInside];

    item = [[UIBarButtonItem alloc] initWithCustomView:button];

    return item;
}

@end
