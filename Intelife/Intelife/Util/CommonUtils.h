//
//  CommonUtils.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-6-16.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <UIKit/UIKit.h>


@interface CommonUtils : NSObject


+ (NSString *)removeSpaceAndNewline:(NSString *)srcString;
+ (UIColor *)UIColorFromRGB: (NSInteger)rgbValue;
+ (BOOL)isValidateEmail:(NSString *)email;
+ (id)fetchSSIDInfo;
+ (NSString *)getWifiSSID;
+ (UIViewController *)getCurrentVC;

@end
