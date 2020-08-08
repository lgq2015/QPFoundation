//
//  DEMOProtocol+Callback.h
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "DEMOProtocol.h"

@class DEMOOperation;
@class DEMO_RequestHeader;

NS_ASSUME_NONNULL_BEGIN

@interface DEMOProtocol (Callback)

- (DEMO_RequestHeader *)setRequestHeader:(DEMO_RequestHeader *)header
                              withSender:(DEMOOperation *)operation;

@end

NS_ASSUME_NONNULL_END
