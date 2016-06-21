//
//  MonitorInfoModel.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-7-7.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonitorInfoModel : NSObject

@property (strong, nonatomic) NSString *monitorDeviceName;
@property (strong, nonatomic) NSString *monitorDeviceID;
@property (strong, nonatomic) NSString *monitorUsername;
@property (strong, nonatomic) NSString *monitorPassword;

@end
