//
//  MonitorAreaModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-17.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonitorAreaModel : NSObject
{
    int monitorID;
    int roomID;
    NSString *monitorName;
}

@property (nonatomic) int monitorID;
@property (nonatomic) int roomID;
@property (strong, nonatomic) NSString *monitorName;

@end
