//
//  DEMOProtocol+Callback.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "DEMOProtocol+Callback.h"
#import "DEMOOperation.h"
#import "DEMOProtocolClasses.h"

@implementation DEMOProtocol (Callback)

- (DEMO_RequestHeader *)setRequestHeader:(DEMO_RequestHeader *)header
                              withSender:(DEMOOperation *)operation
{
    header.serialno = @"serialno ...";
    header.cmd = [operation.interface objectForKey:QPNetworkingInterfaceName];
    header.userid = @"userid ...";
    header.token = @"token ...";
    return header;
}

@end
