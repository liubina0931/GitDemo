//
//  AlarmInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-10-17.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmInfoModel : NSObject
{
    int alarmType;
    NSString *alarmInfo;
}

@property (nonatomic) int alarmType;
@property (nonatomic, strong) NSString *alarmInfo;

@end
