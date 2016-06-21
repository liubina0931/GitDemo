//
//  SendOrderModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 15-3-9.
//  Copyright (c) 2015年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendOrderModel : NSObject
{
    UInt8 orderID;
    UInt8 resendTimes;
    UInt64 sendTime;
    NSObject *orderObject;
}

@property (nonatomic) UInt8 orderID;
@property (nonatomic) UInt8 resendTimes;
@property (nonatomic) UInt64 sendTime;
@property (nonatomic, strong) NSObject *orderObject;

@end
