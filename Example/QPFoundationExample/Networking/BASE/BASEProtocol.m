//
//  BASEProtocol.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "BASEProtocol.h"

@implementation BASEProtocol

#pragma mark - Initializers

- (instancetype)initWithSourcePath:(NSString *)sourcePath
{
    NSString *name = NSStringFromClass([self class]);
    name = [name stringByReplacingOccurrencesOfString:@"Protocol" withString:@""];
    if ((self = [super initWithName:name])) {
        self.operationClassName = [name stringByAppendingString:@"Operation"];
        self.baseDirectory = [[sourcePath stringByAppendingString:@"/../.."] stringByStandardizingPath];
    }
    return self;
}

#pragma mark - Identifiers

- (NSString *)operationName
{
    return [self.name stringByAppendingString:@"Operation"];
}

- (NSString *)invokeNameForInterface:(QPNetworkingInterfaceModel *)interface
{
    NSString *alias = [interface objectForKey:QPNetworkingInterfaceAlias];
    return [NSString stringWithFormat:@"SVC%@", alias];
}

- (NSString *)enhancedInvokeNameForInterface:(QPNetworkingInterfaceModel *)interface
{
    NSString *alias = [interface objectForKey:QPNetworkingInterfaceAlias];
    return [NSString stringWithFormat:@"XVC%@", alias];
}

#pragma mark - Outputs

- (void)dealAtSubdirectory:(NSString *)subdirectory block:(void (^)(NSString *directory))block
{
    NSString *baseDirectory = self.baseDirectory;
    NSString *targetDirectory = [baseDirectory stringByAppendingFormat:@"/%@", subdirectory];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExists = [fileManager fileExistsAtPath:baseDirectory isDirectory:&isDirectory];

    if (isExists && isDirectory) {
        [fileManager createDirectoryAtPath:targetDirectory
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
        if (block) {
            block(targetDirectory);
        }
    }
}

- (void)make
{
    [self dealAtSubdirectory:@"Dynamic" block:^(NSString *directory) {
        [self makeToDirectory:directory];
    }];
}

- (void)stub
{
    [self dealAtSubdirectory:@"Stubs" block:^(NSString *directory) {
        [self stubToDirectory:directory];
    }];
}

@end
