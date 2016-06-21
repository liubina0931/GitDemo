//
//  UserInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-10-15.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject
{
    int userType;
    NSString *userName;
    NSString *userValue;
}

@property (nonatomic) int userType;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userValue;

@end
