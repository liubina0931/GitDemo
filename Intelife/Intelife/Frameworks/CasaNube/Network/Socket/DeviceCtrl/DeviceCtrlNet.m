//
//  DeviceCtrlNet.m
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-4.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import "DeviceCtrlNet.h"
#import "DeviceInfoModel.h"
#import "TimerInfoModel.h"
#import "AppliancesInfoModel.h"
#import "SceneInfoModel.h"
#import "SecurityAreaModel.h"
#import "JSONKit.h"
#import "GlobalVariable.h"
#import "JYNetworkAnalyse.h"
#import "GlobalDefines.h"


//设备控制指令
#define CMD_DEVICE_CTRL                 @"20"
#define CMD_ROOM_NUM                    @"21"
#define CMD_REQUEST_TIMER_STATUS        @"23"
#define CMD_TIMER_CTRL                  @"24"
#define CMD_SCENE_CTRL                  @"25"
#define CMD_ELECTRONIC_CTRL             @"26"
#define CMD_READ_KT_STATUS              @"28"
#define CMD_READ_DEVICE_STATUS          @"29"
#define CMD_SECURITY_AREA_CTRL          @"31"
#define CMD_READ_SECURITYAREA_STATUS    @"32"
#define CMD_RESET_ALARM_CTRL            @"34"
#define CMD_CONFIRM_PASSWORD            @"35"
#define CMD_FACTORY_SETTING             @"40"
#define CMD_ALLOW_DEVICE                @"41"
#define CMD_ADD_SCENE                   @"50"
#define CMD_SECURITY_ARMING_CTRL        @"55"
#define CMD_SET_GATEWAY_TIME_ZONE       @"57"
#define CMD_READ_ALARM_MESSAGE          @"58"
#define CMD_ADD_APPLIANCE               @"59"
#define CMD_GET_APPLIANCE_LIST          @"5A"
#define CMD_LEARN_APPLIANCE_ORDER       @"5B"
#define CMD_DELETE_APPLIANCE_ORDER      @"5C"
#define CMD_DELETE_APPLIANCE            @"5D"
#define CMD_GET_APPLIANCE_LEARNED_ORDER @"5E"
#define CMD_APPLIANCE_CTRL              @"5F"
#define CMD_GET_MINI_GATEWAY_WIFI_LIST  @"61"
#define CMD_SET_MINI_GATEWAY_WIFI       @"62"
#define CMD_GET_MINI_GATEWAY_CONNECTED_WIFI     @"63"

//痩网关控制指令
#define GATEWAY_ALLOW_DEVICE            @"03"
#define GATEWAY_FORBID_DEVICE           @"04"
#define GATEWAY_SCAN_DEVICE             @"05"

//语言设置
#define LANGUAGE_ENGLISH    @"0"
#define LANGUAGE_CHINESES   @"1"
#define LANGUAGE_CHINESET   @"2"
#define LANGUAGE_VIETNAMESE @"3"

#define TYPE_ACTIVITY_SCENE     0
#define TYPE_ACTIVITY_LINKAGE   1
#define TYPE_ACTICITY_TIMER     2

#define LINKAGE_NORMAL_ENTER            0
#define LINKAGE_NORMAL_QUIT             1
#define LINKAGE_ARMING_ENTER            0
#define LINKAGE_ARMING_QUIT             1
#define LINKAGE_DISARMING_ENTER         2
#define LINKAGE_DISARMING_QUITE         3

@implementation DeviceCtrlNet

SYNTHESIZE_SINGLETON_FOR_CLASS(DeviceCtrlNet);

- (id)init
{
    if(self = [super init])
    {
        appDelegate = [[UIApplication sharedApplication] delegate];
        sendJsonDic = [[NSMutableDictionary alloc] init];
        cmdData = [[NSMutableString alloc] init];
    }
    
    return self;
}

- (void)allowToAddDevice
{
    [cmdData setString:GATEWAY_ALLOW_DEVICE];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_ALLOW_DEVICE withName:@""];
}

- (void)gatewayFactorySetting:(int)language
{
    NSString *languageStr = nil;
    if (language == -1)
        languageStr = LANGUAGE_ENGLISH;
    else
        languageStr = [NSString stringWithFormat:@"%d",language];
    [cmdData setString:languageStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_FACTORY_SETTING withName:@""];
}

- (void)saveCameraLocationForDevice:(DeviceInfoModel *)ctrlDeviceModel withMode:(int)mode
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:[NSString stringWithFormat:@"%d",mode]];
    [cmdData appendString:@"."];
    [cmdData appendString:@"F1"];
    [cmdData appendString:@"."];
    if (mode == 0)
        [cmdData appendString:[NSString stringWithFormat:@"%d",ctrlDeviceModel.cameraLocationArming]];
    else if (mode == 2)
        [cmdData appendString:[NSString stringWithFormat:@"%d",ctrlDeviceModel.cameraLocationDisArming]];
    [cmdData appendString:@"."];
    [cmdData appendString:@"0"];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_ADD_SCENE withName:@""];
}

- (void)readDeviceActivityList:(int)activityType
{
    [cmdData setString:@""];
}

- (void)deviceAllOpen
{
    
}

- (void)deviceAllClose
{
    
}

- (void)deviceOpen:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"1"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)deviceDimmingOpen:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"FF"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)deviceSocketOpen:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    //    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"FDE9"];
    [cmdData appendString:@"."];
    [cmdData appendString:@"1"];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)deviceClose:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"0"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)deviceSocketClose:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    //    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"FDE9"];
    [cmdData appendString:@"."];
    [cmdData appendString:@"0"];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)lightDimming:(DeviceInfoModel *)ctrlDeviceModel dimmingValue:(int)value
{
    NSString *dimmingValue;
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    dimmingValue = [NSString stringWithFormat:@"%x",value];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:dimmingValue];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)curtainOpen:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"1"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)curtainClose:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"0"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)curtainStop:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    roomID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"3"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DEVICE_CTRL withName:@""];
}

- (void)securityArmingDevice:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"0"];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_SECURITY_ARMING_CTRL withName:@""];
}

- (void)securityDisArmingDevice:(DeviceInfoModel *)ctrlDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",ctrlDeviceModel.deviceID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"1"];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_SECURITY_ARMING_CTRL withName:@""];
}

- (void)readDeviceStatus:(DeviceInfoModel *)readDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",readDeviceModel.deviceID];
    roomID = @"FDE8";
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:sendID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_ROOM_NUM withName:@""];
}

- (void)readSocketElectronicStatus:(DeviceInfoModel *)readDeviceModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",readDeviceModel.deviceID];
    roomID = @"FDE9";
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:sendID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_ROOM_NUM withName:@""];
}

- (void)timerOpen:(TimerInfoModel *)timerInfoModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",timerInfoModel.timerID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"1"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_TIMER_CTRL withName:@""];
}

- (void)timerClose:(TimerInfoModel *)timerInfoModel
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",timerInfoModel.timerID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:@"0"];
    //[self deviceCtrl:cmdData];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_TIMER_CTRL withName:@""];
}

- (void)requestTimerStatus
{
    [cmdData setString:@""];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_REQUEST_TIMER_STATUS withName:@""];
}

//- (void)deviceCtrl:(NSString *)ctrlCmd
//{
//    NSString *sendData;
//    [sendJsonDic setObject:CMD_DEVICE_CTRL forKey:@"type"];
//    [sendJsonDic setObject:@"" forKey:@"name"];
//    [sendJsonDic setObject:ctrlCmd forKey:@"CMD"];
//    sendData = [sendJsonDic JSONString];
//    [appDelegate sendToNetWithData:sendData];
//}

- (void)readAlarmMessageFrom:(int)srcIndex to:(int)endIndex
{
    [cmdData setString:@""];
    NSString *srcIndexStr = [NSString stringWithFormat:@"%d",srcIndex];
    NSString *endIndexStr = [NSString stringWithFormat:@"%d",endIndex];
    [cmdData appendString:srcIndexStr];
    [cmdData appendString:@"."];
    [cmdData appendString:endIndexStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_READ_ALARM_MESSAGE withName:@""];
}

- (void)addApplianceWithName:(NSString *)applianceName withType:(int)applianceType toDevice:(DeviceInfoModel *)deviceInfo
{
    if (deviceInfo == nil)
        return;
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",deviceInfo.deviceID];
    roomID = [NSString stringWithFormat:@"%x",deviceInfo.roomID];
    NSString *applianceTypeStr = [NSString stringWithFormat:@"%x", applianceType];
    [cmdData appendString:roomID];
    [cmdData appendString:@"."];
    [cmdData appendString:applianceTypeStr];
    [cmdData appendString:@"."];
    [cmdData appendString:sendID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_ADD_APPLIANCE withName:applianceName];
}

- (void)getApplianceListForDevice:(DeviceInfoModel *)deviceInfo
{
    if (deviceInfo == nil)
        return;
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",deviceInfo.deviceID];
    [cmdData appendString:sendID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_GET_APPLIANCE_LIST withName:@""];
}

- (void)learnApplianceOrder:(AppliancesInfoModel *)applianceInfo withButtonID:(int)buttonID
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",applianceInfo.electronicID];
    NSString *buttonIDStr = [NSString stringWithFormat:@"%x", buttonID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:buttonIDStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_LEARN_APPLIANCE_ORDER withName:@""];
}

- (void)getApplianceLearnedOrderList:(int)applianceID
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",applianceID];
    [cmdData appendString:sendID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_GET_APPLIANCE_LEARNED_ORDER withName:@""];
}

- (void)deleteApplianceOrder:(AppliancesInfoModel *)applianceInfo withButtonID:(int)buttonID
{
    if (applianceInfo == nil)
        return;
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",applianceInfo.electronicID];
    NSString *buttonIDStr = [NSString stringWithFormat:@"%x", buttonID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:buttonIDStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DELETE_APPLIANCE_ORDER withName:@""];
}

- (void)deleteAppliance:(int)deleteApplianceID
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",deleteApplianceID];
    [cmdData appendString:sendID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_DELETE_APPLIANCE withName:@""];
}

- (void)electronicOperation:(AppliancesInfoModel *)applianceInfo withButtonID:(int)buttonID
{
    if (applianceInfo == nil)
        return;
    NSString *buttonIDStr;
    [cmdData setString:@""];
    buttonIDStr = [NSString stringWithFormat:@"%x",buttonID];
    sendID = [NSString stringWithFormat:@"%x",applianceInfo.electronicID];
    //    roomID = [NSString stringWithFormat:@"%x",applianceInfo.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    //    [cmdData appendString:roomID];
    //    [cmdData appendString:@"."];
    [cmdData appendString:buttonIDStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_APPLIANCE_CTRL withName:@""];
}

- (void)readAirConditionStatus:(AppliancesInfoModel *)applianceInfo
{
    if (applianceInfo == nil)
        return;
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",applianceInfo.electronicID];
    roomID = [NSString stringWithFormat:@"%x",applianceInfo.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_READ_KT_STATUS withName:@""];
}

- (void)electronicCtrl:(NSString *)ctrlCmd
{
    NSString *sendData;
    [sendJsonDic setObject:CMD_ELECTRONIC_CTRL forKey:@"type"];
    [sendJsonDic setObject:@"" forKey:@"name"];
    [sendJsonDic setObject:ctrlCmd forKey:@"CMD"];
    sendData = [sendJsonDic JSONString];
    //    [appDelegate sendToNetWithTcpData:sendData];
}

- (void)sceneCtrl:(SceneInfoModel *)sceneInfo
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",sceneInfo.sceneID];
    roomID = [NSString stringWithFormat:@"%x",sceneInfo.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_SCENE_CTRL withName:@""];
}

- (void)securityAreaCtrl:(SecurityAreaModel *)secirityAreaInfo
{
    [cmdData setString:@""];
    sendID = [NSString stringWithFormat:@"%x",secirityAreaInfo.securityAreaID];
    roomID = [NSString stringWithFormat:@"%x",secirityAreaInfo.roomID];
    [cmdData appendString:sendID];
    [cmdData appendString:@"."];
    [cmdData appendString:roomID];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_SECURITY_AREA_CTRL withName:@""];
}

- (void)sendPasswordConformWithCmd:(NSString *)cmd
{
    [self sendDataWithCmd:@"" withCtrlType:CMD_CONFIRM_PASSWORD withName:cmd];
}

- (void)sendResetAlarmWithType:(int)alarmType
{
    [self sendDataWithCmd:[NSString stringWithFormat:@"%x",alarmType] withCtrlType:CMD_RESET_ALARM_CTRL withName:@""];
}

- (void)sendDataWithCmd:(NSString *)ctrlCmd withCtrlType:(NSString *)ctrlType withName:(NSString *)nameStr
{
    NSString *sendData;
    [sendJsonDic setObject:ctrlType forKey:@"type"];
    [sendJsonDic setObject:nameStr forKey:@"name"];
    [sendJsonDic setObject:ctrlCmd forKey:@"CMD"];
    sendData = [sendJsonDic JSONString];
    [JY_NETWORK_INSTANCE sendToNetWithData:sendData withCommunicationMode:communicationMode];
}

- (void)readSecurityAreaStatus
{
    [self sendDataWithCmd:@"" withCtrlType:CMD_READ_SECURITYAREA_STATUS withName:@""];
}

- (void)sendRoomNum:(int)roomNum
{
    [cmdData setString:@""];
    NSString *roomNumStr;
    roomNumStr = [NSString stringWithFormat:@"%x",roomNum];
    [cmdData appendString:roomNumStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_ROOM_NUM withName:@""];
}

- (void)getMiniGatewayWifiList
{
    [cmdData setString:@""];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_GET_MINI_GATEWAY_WIFI_LIST withName:@""];
}

- (void)setMiniGatewayWifiInfo:(NSMutableDictionary *)wifiInfo
{
    NSString *ssidStr = (NSString *)[wifiInfo objectForKey:@"ssid"];
    NSString *passwordStr = (NSString *)[wifiInfo objectForKey:@"password"];
    [cmdData setString:@""];
    [cmdData appendString:ssidStr];
    [cmdData appendString:@"<+"];
    [cmdData appendString:passwordStr];
    [cmdData appendString:@"+>"];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_SET_MINI_GATEWAY_WIFI withName:@""];
}

- (void)getMiniGatewayConnectedWifi
{
    [cmdData setString:@""];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_GET_MINI_GATEWAY_CONNECTED_WIFI withName:@""];
}

- (void)setGatewayTimeZone:(int)timeZone
{
    //获取当前时间
    NSDate *now = [NSDate date];
    NSLog(@"now date is: %@", now);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSString *year = [NSString stringWithFormat:@"%x",(int)[dateComponent year]];
    NSString *month = [NSString stringWithFormat:@"%x",(int)[dateComponent month]];
    NSString *day = [NSString stringWithFormat:@"%x",(int)[dateComponent day]];
    NSString *hour = [NSString stringWithFormat:@"%x",(int)[dateComponent hour]];
    NSString *minute = [NSString stringWithFormat:@"%x",(int)[dateComponent minute]];
    NSString *second = [NSString stringWithFormat:@"%x",(int)[dateComponent second]];
    NSString *weekday = [NSString stringWithFormat:@"%x",(int)([dateComponent weekday] - 1)];
    NSString *timeZoneStr = [NSString stringWithFormat:@"%x",timeZone];
    [cmdData setString:@""];
    [cmdData appendString:year];
    [cmdData appendString:@"."];
    [cmdData appendString:month];
    [cmdData appendString:@"."];
    [cmdData appendString:day];
    [cmdData appendString:@"."];
    [cmdData appendString:hour];
    [cmdData appendString:@"."];
    [cmdData appendString:minute];
    [cmdData appendString:@"."];
    [cmdData appendString:second];
    [cmdData appendString:@"."];
    [cmdData appendString:weekday];
    [cmdData appendString:@"."];
    [cmdData appendString:timeZoneStr];
    [self sendDataWithCmd:cmdData withCtrlType:CMD_SET_GATEWAY_TIME_ZONE withName:@""];
}

- (void)dealloc
{
    [sendJsonDic release];
    [super dealloc];
}

@end
