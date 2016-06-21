//
//  DeviceInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-1.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoModel : NSObject
{
    int deviceID;
    int roomID;
    int deviceType;
    int cameraLocationArming;
    int cameraLocationDisArming;
    NSString *deviceName;
    NSString *deviceValue;
}

@property (nonatomic) int deviceID;
@property (nonatomic) int roomID;
@property (nonatomic) int deviceType;
@property (nonatomic) int cameraLocationArming;
@property (nonatomic) int cameraLocationDisArming;
@property (strong, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSString *deviceValue;

@end
