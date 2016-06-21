//
//  FloorInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-17.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloorInfoModel : NSObject
{
    NSString *floorName;
    int floorID;
}

@property (strong, nonatomic) NSString *floorName;
@property (nonatomic) int floorID;

@end
