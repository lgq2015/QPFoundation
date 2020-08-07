//
//  UIViewController+SegueBlockPerformer.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 16/8/22.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <QPFoundation/QPPublicHeader.h>


typedef void (^QPSegueBlockPerformerBlock)(UIStoryboardSegue *segue);


@interface UIViewController (SegueBlockPerformer)

- (void)performSegueWithIdentifier:(NSString *)identifier
                           prepare:(QPSegueBlockPerformerBlock)prepare;

- (void)performSegueWithIdentifier:(NSString *)identifier
                            sender:(id)sender
                           prepare:(QPSegueBlockPerformerBlock)prepare;

@end
