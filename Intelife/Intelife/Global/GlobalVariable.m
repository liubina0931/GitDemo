//
//  GlobalVariable.m
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-6-23.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import "GlobalVariable.h"
#import "GlobalDefines.h"


//@implementation GlobalVariable
//
//@end

UInt8 fsmApplicationStatus;
UInt8 netConnectStatus = NET_CONNECTING;
UInt8 communicationMode = MODE_TRANSIT_CONNECT;
UInt8 serverConnectStatus = NET_UNCONNECTED;
UInt8 tempKeyType = TYPE_TEMP_KEY_LOGIN;
UInt8 loginAccountType = TYPE_LOGIN_ACTIVE;
UInt8 phoneNetworkStatus = STATUS_UNKNOW_NETWORK;
UInt8 p2pLoginStatus = LOGIN_INIT;
UInt8 transitLoginStatus = LOGIN_INIT;
UInt8 cameraLocationCount = 0;
UInt16 gatewayPort = 16899;
UInt64 gatewayMac = 0;
UInt64 currentDeleteGatewayMac = 0;
BOOL isAllowedConnection;
NSMutableString *commonKey = nil;
NSString *tempKey = nil;
NSString *loginUsername = nil;
NSString *loginPassword = nil;
NSString *gatewayIPAddress = @"192.168.66.40";
NSString *gUUID = nil;
NSString *gatewaySymbol = nil;
NSString *monitorMac = nil;
TCPClient *gTCPClient = nil;
GCDAsyncUdpSocket *gUdpClient = nil;


//TIME_REGION timeReginArray[] = {
//    {39600,@"(GMT -11:00)Midway Islands,Samoa Islands"},
//    {36000,@"(GMT -10:00)Hawaii"},
//    {32400,@"(GMT -9:00)Alaska Standard"},
//    {28800,@"(GMT -8:00)Pacific Standard(USA and Canada)"},
//    {25200,@"(GMT -7:00)Mountain StandardPacific Standard"},
//    {21600,@"(GMT -6:00)Central Standard,Mexico City"},
//    {18000,@"(GMT -5:00)Eastern Standard,Lima,Bogota"},
//    {14400,@"(GMT -4:00)Atlantic Standard,Santiago,La Pa"},
//    {12600,@"(GMT -3:30)Newfoundland"},
//    {10800,@"(GMT -3:00)Brasilia,Buenos Aires,Georgetown"},
//    {7200,@"(GMT -2:00)Middle Atlantic"},
//    {3600,@"(GMT -1:00)Cape Verde islands"},
//    {0,@"(GMT)Greewich mean time,London,Lisbon,Casablanca"},
//    {-3600,@"(GMT +1:00)Brussels,Paris,Berlin,Rome"},
//    {-7200,@"(GMT +2:00)Athens,Jerusalem,Cairo"},
//    {-10800,@"(GMT +3:00)Nairobi,Riyadh,Moscow"},
//    {-12600,@"(GMT +3:30)Tehran"},
//    {-14400,@"(GMT +4:00)Baku,Tbilisi,AbuDhabi"},
//    {-16200,@"(GMT +4:30)Kabul"},
//    {-18000,@"(GMT +5:00)Islamabad,Karachi"},
//    {-19800,@"(GMT +5:30)Bombay,Calcutta,Madras"},
//    {-21600,@"(GMT +6:00)Almaty,Novosibirsk"},
//    {-25200,@"(GMT +7:00)Bangkok,Hanoi,Jakarta"},
//    {-28800,@"(GMT +8:00)Beijing,Singapore"},
//    {-32400,@"(GMT +9:00)Seoul,Yakutsk"},
//    {-34200,@"(GMT +9:30)Darwin"},
//    {-36000,@"(GMT +10:00)Melbourne,Sydney"},
//    {-39600,@"(GMT +11:00)Magadan"},
//    {-43200,@"(GMT +12:00)Auckland,Wellington"}
//};
