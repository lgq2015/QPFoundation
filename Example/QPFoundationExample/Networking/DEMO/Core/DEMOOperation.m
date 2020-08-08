//
//  DEMOOperation.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "DEMOOperation.h"

@implementation DEMOOperation

#pragma mark - 报文转换。

- (void)handleRequestDictionaryToRaw
{
    if (self.requestDictionary) {
        self.requestRaw = [NSJSONSerialization dataWithJSONObject:self.requestDictionary options:NSJSONWritingPrettyPrinted error:NULL];
    }
}

- (void)handleResponseRawToDictionary
{
    if (self.responseRaw) {
        self.responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseRaw options:0 error:NULL];
    }
}

#pragma mark - 返回校验。

- (void)verify
{
    // 解析返回报文中的返回码及描述信息。

    NSString *rspcode = [self.responseObject valueForKeyPath:@"head.rspcode"];
    NSString *rspdesc = [self.responseObject valueForKeyPath:@"head.rspdesc"];

    if (!rspcode) {
        rspcode = @"-1";
        rspdesc = QPNvlString(self.responseRaw, @"系统繁忙，请稍后再试！");
    }

    self.rspcode = rspcode;
    self.rspdesc = rspdesc;

    // 校验返回码，确认网络请求是否成功。

    BOOL verificationPassed = NO;

    if (self.verifiationBlock) {
        verificationPassed = self.verifiationBlock(self);
    }
    else if ([rspcode integerValue] == 0) {
        verificationPassed = YES;
    }

    self.verificationPassed = verificationPassed;

    // 如果请求失败，生成错误信息并保存。

    if (!verificationPassed) {
        [self handleErrorWithErrorCode:rspcode errorMessage:rspdesc];
    }
}

#pragma mark - 网络请求。

- (void)asynchronous
{
    // 打印接口信息。

    NSString *apidesc = [self.interface objectForKey:QPNetworkingInterfaceDescription];
    void (^apilog)(NSString *, ...) = ^(NSString *format, ...) {
        va_list arguments;
        va_start(arguments, format);
        NSString *info = [[NSString alloc] initWithFormat:format arguments:arguments];
        va_end(arguments);
        NSLog(@"%@ %@ %@", self, apidesc, info);
    };

    // 标记接口调用失败信息。

    void (^setApiError)(NSString *, NSString *) = ^void(NSString *code, NSString *message) {
        [self handleErrorWithErrorCode:code errorMessage:message];
    };

    // 处理通讯失败的情况。

    BOOL (^communicationFailureBlock)(void) = ^{
        apilog(@"发生错误：\n%@", self.error);

        // 将接口调用成功与否的判断权限交由调用者去决定。

        if (self.verifiationBlock && self.verifiationBlock(self)) {
            self.communicationSucceeded = YES;
            self.verificationPassed = YES;
        }

        [self callback];

        if (self.cancellable && self.cancelled) {
            apilog(@"已取消当前请求！");
        }
        else if (!self.succeeded) {
            apilog(@"网络连接失败，请检查网络连接情况！");
        }

        return NO;
    };

    // 通讯开始，生成请求报文。

    BOOL (^communicationInitialBlock)(void) = ^{
        NSException *conversionException = nil;

        @try {
            [self handleRequestObjectCallback];
            [self handleRequestObjectToDictionary];
            [self handleRequestDictionaryToRaw];
        }
        @catch (NSException *exception) {
            conversionException = exception;
        }

        apilog(@"请求报文：\n%@", self.requestDictionary ?: self.requestRaw);

        if (conversionException) {
            setApiError(conversionException.name, conversionException.reason);
            return communicationFailureBlock();
        }

        if (!self.requestRaw) {
            setApiError(@"-1", @"请求报文为空");
            return communicationFailureBlock();
        }

        return YES;
    };

    // 通讯结束，解析返回报文。

    BOOL (^communicationSuccessBlock)(void) = ^{
        NSException *conversionException = nil;

        @try {
            [self handleResponseRawToDictionary];
            [self handleResponseDictionaryToObject];
            [self handleResponseObjectCallback];
        }
        @catch (NSException *exception) {
            conversionException = exception;
        }

        apilog(@"返回报文：\n%@", self.responseDictionary ?: self.responseRaw);

        if (conversionException) {
            setApiError(conversionException.name, conversionException.reason);
            return communicationFailureBlock();
        }

        [self verify];
        [self callback];

        if (!self.succeeded) {
            NSString *message = QPNvlString(self.rspdesc, @"未知异常");
            apilog(@"接口调用失败：%@, %@", self.rspcode, message);
        }

        return self.succeeded;
    };

    // 调用网络服务。

    [self communicateWithInitialBlock:communicationInitialBlock
                         successBlock:communicationSuccessBlock
                         failureBlock:communicationFailureBlock];
}

- (void)communicateWithInitialBlock:(BOOL (^)(void))communicationInitialBlock
                       successBlock:(BOOL (^)(void))communicationSuccessBlock
                       failureBlock:(BOOL (^)(void))communicationFailureBlock
{
    // 生成接口请求地址。

    NSString *apiname = [self.interface objectForKey:QPNetworkingInterfaceName];
    NSString *apidesc = [self.interface objectForKey:QPNetworkingInterfaceDescription];
    NSString *apiurl = [NSString stringWithFormat:@"https://www.example.com/api/%@", apiname];
    NSLog(@"%@ %@ 请求地址：%@", self, apidesc, apiurl);

    // 通讯开始，生成请求报文。

    if (communicationInitialBlock && !communicationInitialBlock()) {
        return;
    }

    // 创建URL请求，并初始化HTTP请求头、请求报文等。

    NSURL *url = [NSURL URLWithString:apiurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.requestRaw;

    // 发送URL请求，等待处理结果，并对返回报文进行解析处理。

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        // 设置返回报文。

#if DEBUG
        error = nil;
        NSString *stubPath = [[NSBundle mainBundle] pathForResource:apiname ofType:@"json"];
        self.responseRaw = [NSData dataWithContentsOfFile:stubPath];
#else
        self.responseRaw = data;
#endif

        // 通讯成功，标记对返回报文进行解析处理。

        if (error == nil) {
            self.communicationSucceeded = YES;
            if (communicationSuccessBlock) {
                communicationSuccessBlock();
            }
        }

        // 通讯失败，记录错误信息并进行相应处理。

        else {
            self.error = error;
            if (communicationFailureBlock) {
                communicationFailureBlock();
            }
        }
    }];
    [dataTask resume];
}

@end
