//
//  NSString+HTMLEscape.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/7/27.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/NSString+HTMLEscape.h>

@implementation NSString (HTMLEscape)

- (NSString *)stringByAddingHTMLEscapes
{
    NSString *escapedString = self;

    escapedString = [escapedString
                     stringByReplacingOccurrencesOfString:@"&"
                     withString:@"&amp;"];

    escapedString = [escapedString
                     stringByReplacingOccurrencesOfString:@"\""
                     withString:@"&quot;"];

    escapedString = [escapedString
                     stringByReplacingOccurrencesOfString:@"\'"
                     withString:@"&apos;"];

    escapedString = [escapedString
                     stringByReplacingOccurrencesOfString:@"<"
                     withString:@"&lt;"];

    escapedString = [escapedString
                     stringByReplacingOccurrencesOfString:@">"
                     withString:@"&gt;"];

    return escapedString;
}

- (NSString *)stringByRemovingHTMLEscapes
{
    NSString *unescapedString = self;

    unescapedString = [unescapedString
                       stringByReplacingOccurrencesOfString:@"&amp;"
                       withString:@"&"];

    unescapedString = [unescapedString
                       stringByReplacingOccurrencesOfString:@"&quot;"
                       withString:@"\""];

    unescapedString = [unescapedString
                       stringByReplacingOccurrencesOfString:@"&apos;"
                       withString:@"\'"];

    unescapedString = [unescapedString
                       stringByReplacingOccurrencesOfString:@"&lt;"
                       withString:@"<"];

    unescapedString = [unescapedString
                       stringByReplacingOccurrencesOfString:@"&gt;"
                       withString:@">"];

    return unescapedString;
}

@end
