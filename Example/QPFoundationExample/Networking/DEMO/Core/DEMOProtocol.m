//
//  DEMOProtocol.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "DEMOProtocol.h"

@implementation DEMOProtocol

+ (void)load
{
    @autoreleasepool {
        NSString *sourcePath = [NSString stringWithUTF8String:__FILE__];
        QPNetworkingRegisterProtocol([[[self class] alloc] initWithSourcePath:sourcePath]);
    }
}

@end
