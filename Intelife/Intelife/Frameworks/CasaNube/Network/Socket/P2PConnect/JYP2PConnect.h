//
//  JYP2PConnect.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-6-15.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"


@interface JYP2PConnect : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(JYP2PConnect);


- (void)getUdpTempLoginKey;     //获取UDP登陆临时密钥
- (void)getTcpTempLoginKey;     //获取TCP登陆临时密钥
- (void)clientLoginAccount;     //客户端登陆服务器
- (void)clientLogoutAccount;    //客户端注销登陆
- (void)findGatewayIP;          //搜索局域网内网关IP
- (void)findOnlineGateway;      //搜索局域网内在线网关
- (void)requestConnectWithCommunicationType:(NSString *)communicationType;  //请求连接
- (void)registAccountwithUserName:(NSString *)userName withPassword:(NSString *)password withEmail:(NSString *)email;
- (void)editPasswordWithOldPassword:(NSString *)oldPassword withSetPassword:(NSString *)setPassword;
- (void)findPasswordWithUserName:(NSString *)userName;
- (void)loginToServerWithCommunicationType:(NSString *)type;
- (void)p2pReloginToServer;
- (void)clientTryP2PConnectWithIP:(NSString *)host withPort:(UInt16)port;
- (void)clientStartP2PConnectWithMac:(long long)mac;
- (void)noticeP2PConnectSuccess;
- (void)noticeP2PConnectFailed;
- (void)clientCloseTransitConnect;
- (void)clientDataTransit:(long long)mac;   //客户端中转连接
- (void)clientAddDeviceWithMac:(long long)mac;
- (void)clientDeleteDeviceWithMac:(long long)mac;
- (void)getGatewayP2PMac:(NSString *)gatewaySymbol;     //获取网关P2P MAC地址


@end
