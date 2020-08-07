//
//  UIViewController+SegueBlockPerformer.m
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/8/22.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/UIViewController+SegueBlockPerformer.h>
#import <QPFoundation/NSObject+Swizzling.h>
#import <QPFoundation/NSObject+Association.h>


QP_STATIC_KEYNAME(QPDictionaryForPrepareBlocksKey);


@implementation UIViewController (SegueBlockPerformer)

#pragma mark - 初始化及销毁。

+ (void)load
{
    [[UIViewController class]
     swizzleSelector:@selector(prepareForSegue:sender:)
     toSelector:@selector(prepareBlockForSegue:sender:)];
}

#pragma mark - 属性访问相关。

- (NSMutableDictionary *)dictionaryForPrepareBlocksWithCreateIfNotExists:(BOOL)createIfNotExists
{
    NSMutableDictionary *dictionary = nil;
    NSString *key = QPDictionaryForPrepareBlocksKey;

    dictionary = [self associatedValueForKey:key];
    if (!dictionary && createIfNotExists) {
        dictionary = [[NSMutableDictionary alloc] init];
        [self setAssociatedValue:dictionary forKey:key];
    }

    return dictionary;
}

#pragma mark - 执行跳转连接。

- (void)performSegueWithIdentifier:(NSString *)identifier
                           prepare:(QPSegueBlockPerformerBlock)prepare
{
    [self performSegueWithIdentifier:identifier sender:nil prepare:prepare];
}

- (void)performSegueWithIdentifier:(NSString *)identifier
                            sender:(id)sender
                           prepare:(QPSegueBlockPerformerBlock)prepare
{
    NSMutableDictionary *dictionary = nil;
    dictionary = [self dictionaryForPrepareBlocksWithCreateIfNotExists:YES];
    [dictionary setValue:prepare forKey:QPNonnullString(identifier)];
    [self performSegueWithIdentifier:identifier sender:sender];
}

#pragma mark - 预处理跳转连接。

- (void)prepareBlockForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary *dictionary = nil;
    dictionary = [self dictionaryForPrepareBlocksWithCreateIfNotExists:YES];

    NSString *identifier = QPNonnullString([segue identifier]);
    QPSegueBlockPerformerBlock prepare = nil;
    prepare = [dictionary objectForKey:identifier];

    if (prepare) {
        prepare(segue);
        prepare = nil;
        [dictionary setValue:prepare forKey:identifier];
    }

    [self prepareBlockForSegue:segue sender:sender];
}

@end
