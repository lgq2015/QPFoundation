//
//  NSString+HTMLEscape.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/7/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface NSString (HTMLEscape)

- (NSString *)stringByAddingHTMLEscapes;
- (NSString *)stringByRemovingHTMLEscapes;

@end
