//
//  CommonUtils.m
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-6-16.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import "CommonUtils.h"
//#import "GloabalDefines.h"

@implementation CommonUtils


+ (NSString *)removeSpaceAndNewline:(NSString *)srcString
{
    NSString *removeString = [srcString stringByReplacingOccurrencesOfString:@" " withString:@" "];
    removeString = [removeString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    removeString = [removeString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return removeString;
}

+ (UIColor *)UIColorFromRGB: (NSInteger)rgbValue
{
    UIColor *rgbColor = [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                                        green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0
                                         blue: ((float)(rgbValue & 0xFF)) / 255.0
                                        alpha: 1.0];
    
    return rgbColor;
}

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
//    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

+ (NSString *)getWifiSSID
{
    //check wifi sid
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [ifs objectForKey:@"SSID"];
    NSLog(@"current_wifi_ssid：%@",ssid);
    return ssid;
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


@end
