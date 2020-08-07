//
//  UITabBarItem+Assignment.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 15/12/17.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UITabBarItem+Assignment.h>

@implementation UITabBarItem (Assignment)

- (void)assignCopy:(UITabBarItem *)other
{
    self.title = other.title;
    self.image = other.image;
    self.imageInsets = other.imageInsets;
    self.tag = other.tag;
    self.enabled = other.enabled;

    if ([other respondsToSelector:@selector(landscapeImagePhone)]) {
        [self setLandscapeImagePhone:[other landscapeImagePhone]];
        [self setLandscapeImagePhoneInsets:[other landscapeImagePhoneInsets]];
    }

    UIControlState states[] = {
        UIControlStateNormal,
        UIControlStateSelected,
        UIControlStateDisabled
    };

    for (int i = 0; i < sizeof(states) / sizeof(states[0]); ++i) {
        NSDictionary *textAttributes = [other titleTextAttributesForState:states[i]];
        [self setTitleTextAttributes:textAttributes forState:states[i]];
    }

    self.badgeValue = other.badgeValue;
    self.selectedImage = other.selectedImage;
    self.titlePositionAdjustment = other.titlePositionAdjustment;
}

@end
