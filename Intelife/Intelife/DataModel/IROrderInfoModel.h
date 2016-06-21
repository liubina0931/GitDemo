//
//  IROrderInfoModel.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-9-21.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IROrderInfoModel : NSObject

@property (nonatomic) int applianceID;
@property (nonatomic) int orderID;
@property (nonatomic) int status;
@property (strong, nonatomic) NSString *orderName;

@end
