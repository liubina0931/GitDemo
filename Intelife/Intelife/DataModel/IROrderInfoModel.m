//
//  IROrderInfoModel.m
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-9-21.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import "IROrderInfoModel.h"

@implementation IROrderInfoModel
@synthesize applianceID, orderID, status, orderName;


- (id)init
{
    self = [super init];
    if (self)
    {
        applianceID = 0;
        orderID = 0;
        status = 0;
    }
    return self;
}

@end
