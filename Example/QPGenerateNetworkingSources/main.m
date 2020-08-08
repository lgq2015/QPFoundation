//
//  main.m
//  QPGenerateNetworkingSources
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QPFoundation/QPFoundation.h>


void QPNetworkingExceptionHandler(NSException *exception)
{
    NSString *exceptionDescription =
    [NSString stringWithFormat:
     @"================================================================\n"
     @"Exception Name: %@\n"
     @"Exception Reason: %@\n"
     @"User Info: %@\n"
     @"================================================================\n",
     [exception name],
     [exception reason],
     [exception userInfo]];
    fprintf(stderr, "%s", [exceptionDescription UTF8String]);
    exit(EXIT_FAILURE);
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSSetUncaughtExceptionHandler(&QPNetworkingExceptionHandler);
        NSArray *protocols = [QPNetworkingGetRegisteredProtocols() allValues];
        for (QPNetworkingProtocol *protocol in protocols) {
            [protocol make];
            [protocol stub];
        }
    }
    return 0;
}
