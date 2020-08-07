//
//  QPFoundation.h
//  QPFoundation
//
//  Created by keqiongpan@163.com on 2020/08/07.
//  Copyright (c) 2020 Qiongpan Ke. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for QPFoundation.
FOUNDATION_EXPORT double QPFoundationVersionNumber;

//! Project version string for QPFoundation.
FOUNDATION_EXPORT const unsigned char QPFoundationVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <QPFoundation/PublicHeader.h>

#import <QPFoundation/QPPublicHeader.h>

#if (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR)

#import <QPFoundation/QPFoundationPreferences.h>
#import <QPFoundation/QPApplicationFramework.h>
#import <QPFoundation/QPNetworking.h>
#import <QPFoundation/QPEnhancedFoundation.h>
#import <QPFoundation/QPEnhancedUI.h>
#import <QPFoundation/QPEnhancedDebugging.h>

#else /* (TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) */

#import <QPFoundation/QPNetworking.h>

#endif /* !(TARGET_OS_IPHONE || TARGET_OS_SIMULATOR) */
