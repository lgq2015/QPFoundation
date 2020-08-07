//
//  UIBarButtonItem+Factory.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/17.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface UIBarButtonItem (Factory)

+ (instancetype)itemWithTitle:(NSString *)title
                       target:(id)target
                       action:(SEL)action;

+ (instancetype)itemWithImage:(NSString *)imageName;

+ (instancetype)itemWithImage:(NSString *)imageName
                       target:(id)target
                       action:(SEL)action;

+ (instancetype)itemWithImage:(NSString *)imageName
             highlightedImage:(NSString *)highlightedImageName
                       target:(id)target
                       action:(SEL)action;

@end
