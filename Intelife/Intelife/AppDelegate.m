//
//  AppDelegate.m
//  Intelife
//
//  Created by 刘斌 on 16-4-19.
//  Copyright (c) 2016年 richdataco. All rights reserved.
//

#import "AppDelegate.h"
#import "JYService.h"
#import "CommonConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize gGatewayAddedList, gDeviceList, gApplianceList, gSceneList;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self applicationInit];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

void uncaughtExceptionHandler(NSException *exception) {
    DLog(@"CRASH: %@", exception);
    DLog(@"Stack Trace: %@",[exception callStackSymbols]);
    // Internal error reporting
}

- (void)applicationInit {
    [self initData];
    [JYService JYServiceInitWithDelegate:self];  //初始化家云服务
}

- (void)initData {
    DLog(@"Init Data");
    self.gGatewayAddedList = [[NSMutableArray alloc] init];
    self.gDeviceList = [[NSMutableArray alloc] init];
    self.gApplianceList = [[NSMutableArray alloc] init];
    self.gSceneList = [[NSMutableArray alloc] init];
    [gGatewayAddedList addObject:@"Home"];
    [gGatewayAddedList addObject:@"Beach House"];
    [gGatewayAddedList addObject:@"Office"];
    [gDeviceList addObject:@"Smart Plug 01"];
    [gDeviceList addObject:@"Smart Plug 02"];
    [gDeviceList addObject:@"Smart Plug 03"];
    [gApplianceList addObject:@"TV"];
    [gApplianceList addObject:@"DVD"];
    [gApplianceList addObject:@"Aircon"];
    [gSceneList addObject:@"Good morning"];
    [gSceneList addObject:@"Ambiance"];
    [gSceneList addObject:@"Midday"];
    [gSceneList addObject:@"Party"];
    [gSceneList addObject:@"Sleepy time"];
}

- (void)jyReceiveServerData:(NSDictionary *)serverData {
    NSArray *arrayResult = nil;
    UInt16 cmd = [[serverData objectForKey:@"cmd"] integerValue];
    UInt16 returnValue = [[serverData objectForKey:@"ret"] integerValue];
    cmd = cmd & 0x7F;
    switch (cmd)
    {
        case CLIENT_REGISTER_ACCOUNT:
            switch (returnValue)
            {
                case RETURN_SUCCESS:
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"RegistSuccess") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_USERNAME_EXIST:
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountAlreadyExist") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_USERNAME_FORMAT_ERROR:
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountFormatError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_PASSWORD_FORMAT_ERROR:
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"PasswordFormatError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_EMAIL_FORMAT_ERROR:
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"EmailFormatError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                    
                default:
                    break;
            }
            break;
        case CLIENT_LOGIN_ACCOUNT:
            switch (returnValue) {
                case RETURN_SUCCESS:
                    NSLog(@"Login success, getting gateway added list.");
                    [self.gGatewayAddedList removeAllObjects];
                    arrayResult = [serverData objectForKey:@"dev"];
                    for (int i=0; i< [arrayResult count]; i++) {
                        //                NSMutableDictionary *gatewayDic = [[NSMutableDictionary alloc] init];
                        NSDictionary *dic = [arrayResult objectAtIndex:i];
                        GatewayInfoModel *gatewayInfo = [[GatewayInfoModel alloc] init];
                        gatewayInfo.gatewayname = LocalizedString(@"SmartGateway");
                        gatewayInfo.gatewayMacAddress = [(NSNumber *)[dic objectForKey:@"mac"] longLongValue];
                        [self.gGatewayAddedList addObject:gatewayInfo];
                    }
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountLoginSuccess") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_PASSWORD_ERROR:
                    NSLog(@"密码错误");
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"PasswordError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_USER_NOT_EXIST:
                    NSLog(@"用户名不存在");
                    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountNotExist") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                    break;
                case RETURN_CLIENT_RELOGIN:
                    NSLog(@"重复登录");
                    break;
                    
                default:
                    break;
            }
            break;
            
        case CLIENT_TRANSIT_CONNECT:
            switch (returnValue) {
                case RETURN_SUCCESS:
                    //                    NSLog(@"开始中转连接");
                    //                    [JY_P2P_INSTANCE requestConnectWithCommunicationType:communicationType];
                    break;
                case RETURN_DEVICE_UNLOGIN:
                    // NSLog(@"TCP--网关未登录");
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

@end
