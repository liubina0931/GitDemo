//
//  DeviceCtrlNet.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-4.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "SynthesizeSingleton.h"

@class DeviceInfoModel;
@class AppliancesInfoModel;
@class SecurityAreaModel;
@class SceneInfoModel;
@class TimerInfoModel;

@interface DeviceCtrlNet : NSObject
{
    AppDelegate *appDelegate;
    NSMutableDictionary *sendJsonDic;
    //NSString *sendData;
    NSString *sendID;
    NSString *roomID;
    // NSString *dimmingValue;
    NSMutableString *cmdData;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DeviceCtrlNet);


- (void)allowToAddDevice;   //允许加入设备
- (void)gatewayFactorySetting:(int)language;    //网关出厂设置
- (void)saveCameraLocationForDevice:(DeviceInfoModel *)ctrlDeviceModel withMode:(int)mode;  //保存摄像头预置位(摄像头网关)
- (void)deviceAllOpen;  //设备全开控制
- (void)deviceAllClose; //设备全关控制
- (void)deviceOpen:(DeviceInfoModel *)ctrlDeviceModel;          //打开一个设备
- (void)deviceSocketOpen:(DeviceInfoModel *)ctrlDeviceModel;    //打开智能插座设备
- (void)deviceDimmingOpen:(DeviceInfoModel *)ctrlDeviceModel;   //控制设备调光
- (void)deviceClose:(DeviceInfoModel *)ctrlDeviceModel;
- (void)deviceSocketClose:(DeviceInfoModel *)ctrlDeviceModel;
- (void)lightDimming:(DeviceInfoModel *)ctrlDeviceModel dimmingValue:(int)value;
- (void)curtainOpen:(DeviceInfoModel *)ctrlDeviceModel;
- (void)curtainClose:(DeviceInfoModel *)ctrlDeviceModel;
- (void)curtainStop:(DeviceInfoModel *)ctrlDeviceModel;
- (void)securityArmingDevice:(DeviceInfoModel *)ctrlDeviceModel;    //单个设备布防
- (void)securityDisArmingDevice:(DeviceInfoModel *)ctrlDeviceModel; //单个设备撤防
- (void)readDeviceStatus:(DeviceInfoModel *)readDeviceModel;        //读取设备状态
- (void)readSocketElectronicStatus:(DeviceInfoModel *)readDeviceModel;  //读取智能插座电量数据
- (void)timerOpen:(TimerInfoModel *)timerInfoModel;     //开启定时器
- (void)timerClose:(TimerInfoModel *)timerInfoModel;    //停止定时器
- (void)requestTimerStatus;     //读取定时器状态
//- (void)deviceCtrl:(NSString *)ctrlCmd;
- (void)sendRoomNum:(int)roomNum;   //发送房间号
- (void)readAlarmMessageFrom:(int)srcIndex to:(int)endIndex;    //按照索引读取报警信息
- (void)addApplianceWithName:(NSString *)applianceName withType:(int)applianceType toDevice:(DeviceInfoModel *)deviceInfo;      //添加家电
- (void)getApplianceListForDevice:(DeviceInfoModel *)deviceInfo;    //获取家电列表
- (void)learnApplianceOrder:(AppliancesInfoModel *)applianceInfo withButtonID:(int)buttonID;    //学习家电指令
- (void)getApplianceLearnedOrderList:(int)applianceID;      //获取家电已学习指令列表
- (void)deleteApplianceOrder:(AppliancesInfoModel *)applianceInfo withButtonID:(int)buttonID;   //删除家电指令
- (void)deleteAppliance:(int)deleteApplianceID;     //删除家电
- (void)electronicOperation:(AppliancesInfoModel *)applianceInfo withButtonID:(int)buttonID;    //家电控制
- (void)readAirConditionStatus:(AppliancesInfoModel *)applianceInfo;        //读取空调状态
- (void)securityAreaCtrl:(SecurityAreaModel *)secirityAreaInfo;             //防区控制
- (void)sceneCtrl:(SceneInfoModel *)sceneInfo;          //场景控制
- (void)sendPasswordConformWithCmd:(NSString *)cmd;
- (void)sendResetAlarmWithType:(int)alarmType;          //解除报警
- (void)readSecurityAreaStatus;             //读取防区状态
- (void)setGatewayTimeZone:(int)timeZone;   //设置网关时区
- (void)getMiniGatewayWifiList;             //获取Mini网关Wifi列表
- (void)setMiniGatewayWifiInfo:(NSMutableDictionary *)wifiInfo;     //设置Mini网关wifi信息
- (void)getMiniGatewayConnectedWifi;        //获取Mini网关当前连接Wifi信息
@end
