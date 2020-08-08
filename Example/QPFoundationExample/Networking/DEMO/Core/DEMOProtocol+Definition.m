//
//  DEMOProtocol+Definition.m
//  QPFoundationExample
//
//  Created by keqiongpan@163.com on 2020/8/7.
//  Copyright © 2020 Qiongpan Ke. All rights reserved.
//

#import "DEMOProtocol+Definition.h"
#import "DEMOProtocol+Callback.h"

#define QPNetworkingApi(_name, _alias, _request, _response, ...) \
    QPNetworkingInterface(_name, _alias, ({ \
        QPNetworkingNodeModel *QPNetworkingNodeVariable(RequestContent) = (_request); \
        QPNetworkingNodeBegin(REQ); \
        [QPNetworkingCurrentNode setValue:QPLiteralness(__VA_ARGS__(_name) - 请求报文) forKey:QPNetworkingNodeDescription]; \
        QPNetworkingQuoteX(REQ, header, head, RequestHeader, 1, nil, __VA_ARGS__(_name) - 请求报文头); \
        QPNetworkingQuoteX(REQ, request, body, RequestContent, 1, nil, __VA_ARGS__(_name) - 请求报文体); \
        QPNetworkingNodeEnd(); \
    }), body, ({ \
        QPNetworkingNodeModel *QPNetworkingNodeVariable(ResponseContent) = (_response); \
        QPNetworkingNodeBegin(RSP); \
        [QPNetworkingCurrentNode setValue:QPLiteralness(__VA_ARGS__(_name) - 应答报文) forKey:QPNetworkingNodeDescription]; \
        QPNetworkingQuoteX(RSP, header, head, ResponseHeader, 1, nil, __VA_ARGS__(_name) - 应答报文头); \
        QPNetworkingQuoteX(RSP, response, body, ResponseContent, 1, nil, __VA_ARGS__(_name) - 应答报文体); \
        QPNetworkingNodeEnd(); \
    }), body, __VA_ARGS__(_name))

@implementation DEMOProtocol (Definition)

- (id)stubObjectForInterface:(QPNetworkingInterfaceModel *)interface
{
    id stub = [self stubObjectForNode:[self nodeForResponseOfInterface:interface]];
    [stub setValue:@"90016042810214060002" forKeyPath:@"header.serialno"];
    [stub setValue:@"0" forKeyPath:@"header.rspcode"];
    [stub setValue:@"Success" forKeyPath:@"header.rspdesc"];
    [stub setValue:@"10" forKeyPath:@"header.factcount"];
    [stub setValue:@"131" forKeyPath:@"header.totalcount"];
    return stub;
}

- (void)initializeInterfaces
{
    QPNetworkingIndependentNodeBegin(header, RequestHeader, @selector(setRequestHeader:withSender:), 请求报文头);
    QPNetworkingField(header, serialno, 1, 业务流水);
    QPNetworkingField(header, cmd, 1, 接口命令);
    QPNetworkingField(header, userid, 1, 登录用户);
    QPNetworkingField(header, token, 1, 访问票据);
    QPNetworkingIndependentNodeEnd();

    QPNetworkingIndependentNodeBegin(header, ResponseHeader, nil, 应答报文头);
    QPNetworkingField(header, serialno, 1, 业务流水);
    QPNetworkingField(header, rspcode, 1, 返回码);
    QPNetworkingField(header, rspdesc, ?, 描述信息);
    QPNetworkingField(header, factcount, ?, 实际条数);
    QPNetworkingField(header, totalcount, ?, 总记录数);
    QPNetworkingIndependentNodeEnd();

    // MARK: 查询用户信息接口(userinfo)
    QPNetworkingApi(userinfo, QueryUserInformation, ({
        QPNetworkingNodeBegin(request);
        QPNetworkingField(request, userid, ?, 用户编号);
        QPNetworkingField(request, name, ?, 姓名);
        QPNetworkingNodeEnd();
    }), ({
        QPNetworkingNodeBegin(response);
        QPNetworkingField(response, users, *, 用户列表);
        QPNetworkingField(users, userid, 1, 用户编号);
        QPNetworkingField(users, name, ?, 姓名);
        QPNetworkingField(users, age, ?, 年龄);
        QPNetworkingField(users, sex, ?, 性别);
        QPNetworkingField(users, birthday, ?, 生日日期);
        QPNetworkingField(users, register_date, 1, 注册日期);
        QPNetworkingField(users, remark, ?, 备注);
        QPNetworkingNodeEnd();
    }), 1.1 查询用户信息接口);

    // MARK: 系统登录接口(login)
    QPNetworkingApi(login, UserLogin, ({
        QPNetworkingNodeBegin(request);
        QPNetworkingField(request, userid, 1, 用户编号);
        QPNetworkingField(request, password, 1, 登录密码);
        QPNetworkingNodeEnd();
    }), ({
        QPNetworkingNodeBegin(response);
        QPNetworkingField(response, userid, 1, 用户编号);
        QPNetworkingField(response, name, ?, 姓名);
        QPNetworkingField(response, age, ?, 年龄);
        QPNetworkingField(response, sex, ?, 性别);
        QPNetworkingField(response, birthday, ?, 生日日期);
        QPNetworkingField(response, register_date, 1, 注册日期);
        QPNetworkingField(response, remark, ?, 备注);
        QPNetworkingNodeEnd();
    }), 2.1 系统登录接口);

    // MARK: 注销登录接口(logout)
    QPNetworkingApi(logout, UserLogout, ({
        QPNetworkingNodeBegin(request);
        QPNetworkingNodeEnd();
    }), ({
        QPNetworkingNodeBegin(response);
        QPNetworkingNodeEnd();
    }), 2.2 注销登录接口);
}

@end
