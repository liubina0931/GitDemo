//
//  JYService.m
//  SmartHomeSDKDemo
//
//  Created by 刘斌 on 16-1-17.
//  Copyright (c) 2016年 CasaNube. All rights reserved.
//

#import "JYService.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import "GlobalDefines.h"
#import "GlobalVariable.h"
#import "JYNetworkAnalyse.h"
#import "Database.h"

@implementation JYService

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

+ (void)JYServiceInitWithDelegate:(id)delegate
{
    [self initData];
    [self readHardwareInfo];
    [self initNetworkWithDelegate:delegate];
}

+ (void)readHardwareInfo
{
    float screenWidth = SCREEN_WIDTH;
    float screenHeight = SCREEN_HEIGHT;
    if (gUUID == nil || [gUUID isEqualToString:@""])
    {
        gUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [JY_DATABASE_INSTANCE savePhoneSymbol:gUUID];
        [gUUID retain];  //加上这个防止gUUID被自动释放
    }
    NSLog(@"<-------------读取设备信息------------->");
    NSLog(@"screenWidht=%f",screenWidth);
    NSLog(@"screenHeight=%f",screenHeight);
    NSLog(@"systemVersion=%@",[[UIDevice currentDevice] systemVersion]); //版本号
    NSLog(@"model=%@",[[UIDevice currentDevice] model]); //类型（ipad、ipod、iphone）而[[UIDevice currentDevice] userInterfaceIdiom]只能判断iphone和ipad
    NSLog(@"ios6UUID=%@",gUUID);//ios6.0开始available
    NSLog(@"数据库版本：%@",[JY_DATABASE_INSTANCE readStringDataFromTable:@"DatabaseVersion" withColumn:@"version" withSelection:@"_id=?" withSelectionArgs:@"1"]);
}

+ (void)initData
{
    //loginAccountType = [JY_DATABASE_INSTANCE readIntDataFromTable:@"AccountInfo" withColumn:@"loginAccountType" withSelection:@"_id=?" withSelectionArgs:@"1"];
    gatewayMac = [[JY_DATABASE_INSTANCE readStringDataFromTable:@"RemoteGatewayInfo" withColumn:@"gatewayMac" withSelection:@"_id=?" withSelectionArgs:@"1"] longLongValue];
    gUUID = [JY_DATABASE_INSTANCE readStringDataFromTable:@"PhoneSymbolInfo" withColumn:@"uuid" withSelection:@"_id=?" withSelectionArgs:@"1"];
    NSString *connectAllowStr = [JY_DATABASE_INSTANCE readStringDataFromTable:@"OtherConfig" withColumn:@"connectAllow" withSelection:@"_id=?" withSelectionArgs:@"1"];
    isAllowedConnection = ([connectAllowStr isEqualToString:@"1"]) ? YES : NO;
    [gUUID retain];  //加上这个防止gUUID被自动释放
    loginAccountType = TYPE_LOGIN_AUTO;
}

+ (void)initNetworkWithDelegate:(id)delegate
{
    [JY_NETWORK_INSTANCE initNetworkWithDelegate:delegate];
}

@end
