//
//  RoomInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-1.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomInfoModel : NSObject
{
    NSString *roomName;
    int roomID;
}

@property (strong, nonatomic) NSString *roomName;
@property (nonatomic) int roomID;

@end
