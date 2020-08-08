//
//  DEMOOperation.h
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DEMOOperation : QPNetworkingOperation

/**
 *  设置校验返回报文的回调block，用于判断返回报文是否调用成功。
 */
@property (nonatomic, copy) BOOL (^verifiationBlock)(DEMOOperation *operation);
@property (nonatomic, copy) NSString *rspcode;                  // 报文返回编码。
@property (nonatomic, copy) NSString *rspdesc;                  // 报文返回信息。

@end

NS_ASSUME_NONNULL_END
