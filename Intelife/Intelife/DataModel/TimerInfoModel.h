//
//  TimerInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-11-13.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerInfoModel : NSObject
{
    NSString *timerName;
    NSString *timerValue;
    int timerID;
    
}

@property (strong, nonatomic) NSString *timerName;
@property (strong, nonatomic) NSString *timerValue;
@property (nonatomic) int timerID;


@end
