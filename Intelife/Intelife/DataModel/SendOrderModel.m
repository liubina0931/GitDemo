//
//  SendOrderModel.m
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 15-3-9.
//  Copyright (c) 2015年 JY_SmartHome. All rights reserved.
//

#import "SendOrderModel.h"

@implementation SendOrderModel
@synthesize orderID, resendTimes, sendTime;
@synthesize orderObject;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.orderID = 0;
        self.resendTimes = 0;
    }
    return self;
}

@end
