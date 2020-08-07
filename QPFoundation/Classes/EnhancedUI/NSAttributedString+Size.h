//
//  NSAttributedString+Size.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/1/5.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>

@interface NSAttributedString (Size)

- (CGFloat)width;

- (CGFloat)height;

- (CGFloat)heightConstrainedToWidth:(CGFloat)width;

@end
