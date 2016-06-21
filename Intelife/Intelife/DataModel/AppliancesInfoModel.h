//
//  AppliancesInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-17.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppliancesInfoModel : NSObject
{
    int type;
    int electronicID;
    int roomID;
    int status;
    NSString *appliancesName;
}

@property (nonatomic) int type;
@property (nonatomic) int deviceID;
@property (nonatomic) int electronicID;
@property (nonatomic) int roomID;
@property (nonatomic) int status;
@property (strong, nonatomic) NSString *appliancesName;

@end
