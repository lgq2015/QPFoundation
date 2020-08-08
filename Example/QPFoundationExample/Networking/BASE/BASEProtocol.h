//
//  BASEProtocol.h
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BASEProtocol : QPNetworkingProtocol

@property (nonatomic, copy) NSString *baseDirectory;

- (instancetype)initWithSourcePath:(NSString *)sourcePath NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
