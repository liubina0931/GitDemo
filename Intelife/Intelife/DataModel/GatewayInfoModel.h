//
//  GatewayInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 15-3-6.
//  Copyright (c) 2015年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GatewayInfoModel : NSObject
{
    NSString *gatewayname;
    NSString *gatewayIpAddress;
    NSString *monitorID;
    NSString *monitorName;
    long long gatewayMacAddress;
    UInt16 gatewayPort;
    UInt8 gatewayType;
    
}

@property (nonatomic,strong) NSString *gatewayname;
@property (nonatomic,strong) NSString *gatewayIpAddress;
@property (nonatomic,strong) NSString *monitorID;
@property (nonatomic,strong) NSString *monitorName;
@property (nonatomic) long long gatewayMacAddress;
@property (nonatomic) UInt16 gatewayPort;
@property (nonatomic) UInt8 gatewayType;

@end
