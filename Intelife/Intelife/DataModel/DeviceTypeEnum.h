//
//  DeviceTypeEnum.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-8-2.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#ifndef JY_SmartHomeIphone_DeviceTypeEnum_h
#define JY_SmartHomeIphone_DeviceTypeEnum_h


typedef enum//所有指令（设备）类型
{
    AllDevice                       = 0xFF,
    
    Light                           = 0x10,//灯光类 包括普通灯光和可调灯光
    LightGeneral_1CH                = 0x11,//一路不可调灯光
    LightGeneral_2CH                = 0x12,//二路不可调灯光
    LightGeneral_3CH                = 0x13,//三路不可调灯光
    LightGeneral_4CH                = 0x14,//四路不可调灯光
    LightDimmable_1CH               = 0x15,//一路可调灯光
    LightDimmable_2CH               = 0x16,//二路可调灯光
    
    
    Curtain                         = 0x20,//窗帘类
    Curtain_1CH                     = 0x21,//一路窗帘
    Curtain_2CH                     = 0x22,//二路窗帘
    
    Socket                          = 0x30, //插座类
    SmartSocket                     = 0x31, //智能插座
    
    ScenePanel                      = 0x40,//场景面板类
    ScenePanel_4CH                  = 0x44,//四路场景面板
    
    Security                        = 0x50,//安防类，包括烟雾探测器、可燃气体、被动红外
    SecurityDoorway                 = 0x51, // 门磁
    SecurityInfraredDetection       = 0x52,//被动红外
    SecurityOneKeyAlarm             = 0x53,//一键报警器
    SecuritySmokeDetection          = 0x54,//烟雾探测器
    SecurityGasAlarm                = 0x55,//可燃气体
    
    
    
    Sensor                          = 0x60,//传感器类  一般不报警  如：温湿度传感器、空气质量、CO2报警器、光照强度
    SensorAirQuality                = 0x61,//空气质量
    SensorTemperAndHumiSun          = 0x63,//环境质量
    SensorPM2_5                     = 0x64,//PM2.5传感器
    SensorCO2                       = 0x65,//CO2传感器
    SensorFormaldehyde              = 0x67,//甲醛
    
    Appliance                       ,           //家电类
    ApplianceKT                     = 0x00,     //空调
    ApplianceDVD                    = 0x01,     //DVD
    ApplianceTV                     = 0x02,     //电视
    ApplianceMusic                  = 0x03,     //背景音乐
    ApplianceTouYin                 = 0x04,     //幕布
    ApplianceOther                  = 0x05,     //家电其它
    
    OtherType                       = 0xE0,// 其它类型
    IrController                    = 0xE1 //红外伴侣
} DeviceTypeEnum;


#endif
