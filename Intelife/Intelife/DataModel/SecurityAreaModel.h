//
//  SecurityAreaModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-10-11.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityAreaModel : NSObject
{
    int securityAreaID;
    int roomID;
    int imageID;
    NSString *securityAreaName;
}

@property (nonatomic) int securityAreaID;
@property (nonatomic)int roomID;
@property (nonatomic)int imageID;
@property (strong, nonatomic)NSString *securityAreaName;

@end
