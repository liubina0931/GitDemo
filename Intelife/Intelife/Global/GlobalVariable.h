//
//  GlobalVariable.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-6-23.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPClient.h"
#import "GCDAsyncUdpSocket.h"

//@interface GlobalVariable : NSObject
//
//@end

//typedef struct TimeRegion   //设置网关时区
//{
//    int timeZone;
//    NSString *zoneName;
//}TIME_REGION, *PTIME_REGION;

extern UInt8 fsmApplicationStatus;      //应用运行状态
extern UInt8 netConnectStatus;          //网络连接状态
extern UInt8 communicationMode;         //通信模式
extern UInt8 serverConnectStatus;       //服务器连接状态
extern UInt8 tempKeyType;               //临时密钥类型
extern UInt8 loginAccountType;          //登陆账号类型
extern UInt8 phoneNetworkStatus;        //设备网络状态
extern UInt8 p2pLoginStatus;            //P2P登陆状态
extern UInt8 transitLoginStatus;        //中转登陆状态
extern UInt8 cameraLocationCount;       //摄像头预置位计数
extern UInt16 gatewayPort;
extern UInt64 gatewayMac;
extern UInt64 currentDeleteGatewayMac;
extern BOOL isAllowedConnection;
extern NSMutableString *commonKey;
extern NSString *tempKey;
extern NSString *loginUsername;
extern NSString *loginPassword;
extern NSString *gatewayIPAddress;
extern NSString *gUUID;
extern NSString *gatewaySymbol;
extern NSString *monitorMac;
extern TCPClient *gTCPClient;
extern GCDAsyncUdpSocket *gUdpClient;
//extern TIME_REGION timeReginArray[];
