//
//  NSString+UsingEncoding.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/3/23.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSString+UsingEncoding.h>

@implementation NSString (UsingEncoding)

- (NSString *)stringByUsingEncoding:(NSStringEncoding)encoding
{
    NSData *data = [self dataUsingEncoding:NSISOLatin1StringEncoding
                      allowLossyConversion:NO];
    return [[NSString alloc] initWithData:data encoding:encoding];
}

@end
