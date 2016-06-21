//
//  GloabalDefines.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-1-8.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#ifndef Intelife_GlobalDefines_h
#define Intelife_GlobalDefines_h


#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height


#define UDP_BROADCAST_IP    @"255.255.255.255"
#define UDP_BROADCAST_PORT  16899
#define UDP_CLIENT_PORT     /*0*/18658

#define SERVER_IP   /*@"49.213.10.234"@"120.24.236.123"@"192.168.66.119"*/@"www.casanubeserver.com"
#define SERVER_PORT  /*12345*/ 18567

#define GATEWAY_IP      @"192.168.66.166"
#define GATEWAY_PORT    16899

#define FRAME_START_STRING  @"{"
#define FRAME_END_STRING    @"&]"
#define DEFAULT_COMMON_KEY  @"tarasist"

#define USE_P2P_CONNECT     0

//Application生命周期
#define FSM_APPLICATION_DID_FINISH_LAUNCH       0
#define FSM_APPLICATION_DID_BECOME_ACTIVE       1
#define FSM_APPLICATION_WILL_RESIGN_ACTIVE      2
#define FSM_APPLICATION_DID_ENTER_BACKGROUND    3
#define FSM_APPLICATION_WILL_ENTER_FOREGROUND   4

//手机网络连接状态
#define STATUS_UNKNOW_NETWORK   0
#define STATUS_WIFI_NETWORK     1
#define STATUS_WWAN_NETWORK     2
#define STATUS_NOT_REACHABLE    3

//连接状态
#define NET_UNCONNECTED  0x00// 网络失去连接
#define NET_CONNECTING   0x01// 网络正在连接中
#define NET_CONNECTED    0x02// 网络已经连接上
#define NET_UNKOWN       0x03// 网络异常

//连接模式
#define MODE_UNKNOW_CONNECT      0x00   //未知连接模式
#define MODE_P2P_CONNECT         0x01   //P2P连接模式
#define MODE_TRANSIT_CONNECT     0x02   //中转连接模式
#define MODE_DNS_ADDRESS         0x04   //DNS域名模式

//网关类型
#define TYPE_CAMERA_GATEWAY     0xF1    //摄像头网关
#define TYPE_MINI_GATEWAY       0xF2    //痩网关

//tempkey处理类型
#define TYPE_TEMP_KEY_LOGIN             0
#define TYPE_TEMP_KEY_REGIST            1
#define TYPE_TEMP_KEY_EDIT_PASSWORD     2

//功能模式
#define FUNCTION_LOGIN_CONNECTTION      0   //登陆连接
#define FUNCTION_LOCAL_CONNECTTION      1   //本地连接

//登录类型
#define TYPE_LOGIN_INIT     0
#define TYPE_LOGIN_AUTO     1   //自动连接
#define TYPE_LOGIN_ACTIVE   2   //手动连接

//通信方式
#define TYPE_SOCKET_TCP         0
#define TYPE_SOCKET_UDP         1

//登陆状态
#define LOGIN_FAILED    0
#define LOGIN_SUCCESS   1
#define LOGIN_INIT      2
#define LOGIN_SHOW      3

#define P2P_RECONNECT_PERIOD      10    //P2P重连周期
#define CONNECT_TIMEOUT_PERIOD    15    //连接超时周期

//提示Log显示时间
#define SHOWTOAST_TIME_SHORT  1
#define SHOWTOAST_TIME  2

#define TYPE_PASSWORD_DISALARM                      0
#define TYPE_PASSWORD_RESET_ALARM                   1
#define TYPE_PASSWORD_CLEAR_SINGLE_ALARMINFO        2
#define TYPE_PASSWORD_CLEAR_ALL_ALARMINFO           3

#define GET_TCP_TEMP_KEY_SUCCESS    @"0"
#define GET_UDP_TEMP_KEY_SUCCESS    @"1"
#define TCP_LOGIN_ACCOUNT_SUCCESS   @"2"
#define UDP_LOGIN_ACCOUNT_SUCCESS   @"3"
#define REGIST_ACCOUNT_SUCCESS      @"4"
#define USERNAME_ALREADY_EXIST      @"5"
#define FIND_ACCOUNT_SUCCESS        @"6"
#define USERNAME_NOT_EXIST          @"7"
#define ADD_LOCAL_GATEWAY           @"8"
#define ADD_REMOTE_GATEWAY          @"9"
#define ADD_HISTORY_GATEWAY         @"10"
#define LOGOUT_ACCOUNT_SUCCESS      @"11"
#define ADD_GATEWAY_SUCCESS         @"12"
#define DELETE_GATEWAY_SUCCESS      @"13"
#define RELOAD_GATEWAY_CONNECT_LIST @"14"
#define RELOAD_GATEWAY_ADD_LIST     @"15"

//设备列表刷新类型
#define REFRESH_DEVICE_LIST     0
#define NEW_DEVICE_ADDED        1

#define CURRENT_VIEW    [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject]     //获取当前视图

#define JY_NETWORK_INSTANCE     [JYNetworkAnalyse sharedInstance]
#define JY_P2P_INSTANCE         [JYP2PConnect sharedInstance]
#define JY_PROGRESS_HUD         [JYProgressHud sharedInstance]
#define JY_VIDEO_INSTANCE       [HSLVideoFunction sharedInstance]
#define JY_DATABASE_INSTANCE    [Database sharedInstance]
#define JY_DEVICECTRL_INSTANCE  [DeviceCtrlNet sharedInstance]

#define LocalizedString(str) NSLocalizedString(str, nil)

//#define SHOW_ALERT_VIEW(title,msg,cancelBtnTitle,otherBtnTitle,style,alertViewtag)    \
//{ \
//    UIAlertView *alert = [[UIAlertView alloc] \
//                          initWithTitle:title message:msg \
//                          delegate:self \
//                          cancelButtonTitle: cancelBtnTitle \
//                          otherButtonTitles:otherBtnTitle, nil]; \
//    alert.alertViewStyle = style;\
//    alert.tag = alertViewtag;\
//    [alert show];\
//    [alert release];\
//}
//
//#define SHOW_ACTION_SHEET(cancelBtnTitle,destructiveBtnTitle,otherBtnTitle1,otherBtnTitle2,actionTag)  \
//{   \
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] \
//                                  initWithTitle:nil \
//                                  delegate:self \
//                                  cancelButtonTitle:cancelBtnTitle  \
//                                  destructiveButtonTitle:destructiveBtnTitle    \
//                                  otherButtonTitles:otherBtnTitle1,otherBtnTitle2,nil];    \
//    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;   \
//    actionSheet.tag = actionTag; \
//    [actionSheet showInView:self.view]; \
//}


//对话框tag
#define TYPE_ALERTDIALOG_OTHER                      0
#define TYPE_ACTIONSHEET_ADD_GATEWAY                1



//服务器通信指令
#define CLIENT_GET_TEMP_KEY             0x01
#define CLIENT_REGISTER_ACCOUNT         0x02
#define CLIENT_LOGIN_ACCOUNT            0x04
#define CLIENT_ADD_DEVICE               0x05
#define CLIENT_DELETE_DEVICE            0x06

#define CLIENT_START_P2P_CONNECT        0x09
#define DEVICE_THROUGH_CHANNEL          0x0B
#define NOTICE_CLIENT_P2P_CONNECT       0x0C
#define CLIENT_TRY_P2P_CONNECT          0x0D
#define NOTICE_P2P_CONNECT_SUCCESS      0x0E
#define CLIENT_TRANSIT_CONNECT          0x0F
#define CLIENT_DATA_TRANSIT             0x11
#define SERVER_HEART_BEAT               0x13
#define GATEWAY_CONNECT_CLOSE           0x15
#define GATEWAY_CONNECT_AGAIN           0x16
#define EDIT_ACCOUNT_PASSWORD           0x17
#define FIND_ACCOUNT_PASSWORD           0x18
#define CLIENT_LOGOUT_ACCOUNT           0x19
#define CLIENT_GET_GATEWAY_MAC          0x1C
#define BROUNDCAST_FIND_DEVICE          0x20
#define GATEWAY_MAC_ADDRESS             0x20
#define BROUNDCAST_FIND_GATEWAY_IP      0x40

//服务器状态码返回
#define RETURN_SUCCESS                  0x00
#define RETURN_DEVICE_UNLOGIN           0x02
#define RETURN_CLIENT_UNLOGIN           0x03
#define RETURN_LOCAL_LOGIN              0x04
#define RETURN_NOT_SUPPORT              0x06
#define RETURN_USER_NOT_EXIST           0x08
#define RETURN_USERNAME_EXIST           0x0A
#define RETURN_USERNAME_FORMAT_ERROR    0x0B
#define RETURN_PASSWORD_FORMAT_ERROR    0x0C
#define RETURN_PASSWORD_ERROR           0x0D
#define RETURN_DEVICE_NOT_EXIST         0x0E
#define RETURN_EMAIL_FORMAT_ERROR       0x0F
#define RETURN_CLIENT_RELOGIN           0x13
#define RETURN_DEVICE_EXIST             0x14

//传感器状态
#define SENSOR_SUBTYPE_TEMPERATURE  0x00
#define SENSOR_SUBTYPE_HUMIDITY     0x01
#define SENSOR_SUBTYPE_SUNLIGHT     0x02

#define SENSOR_AIRQUALITY_VERYGOOD          0x0000
#define SENSOR_AIRQUALITY_GOOD              0x0100
#define SENSOR_AIRQUALITY_MIDDLE            0x0200
#define SENSOR_AIRQUALITY_PREALARM          0x0300
#define SENSOR_AIRQUALITY_BAD               0x0400

#define SENSOR_GASDETECT_SAFETY               0x0000
#define SENSOR_GASDETECT_PREALARM             0x0001
#define SENSOR_GASDETECT_DANGEROUS            0x0002

#define SENSOR_ROOM_NUM     0xEA60      //传感器状态读取房间号

//报警ID
#define ALARM_PASSIVEINFRARED_LOW_POWER     1//被动红外低电压报警
#define ALARM_PASSIVEINFRARED               2//被动红外入侵报警
#define ALARM_SMOKEDETECT_LOW_POWER         3//烟雾探测低电压报警
#define ALARM_SMOKEDETECT                   4//烟雾探测火灾报警
#define ALARM_SINGLEKEY_LOW_POWER           5//一键报警低电压报警
#define ALARM_SINGLEKEY                     6//一键报警求救报警
#define ALARM_DOORCONTACT_LOW_POWER         7//门磁低电压报警
#define ALARM_DOORCONTACT                   8//门磁入侵报警
#define ALARM_GASDETECT_LEAKAGE             9//可燃气体泄露报警
#define ALARM_GASDETECT_LIFT                10//可燃气体泄露解除

//设备列表设备类型
#define TYPE_DEVICE_GATEWAY     0
#define TYPE_DEVICE_MONITOR     1
#define TYPE_DEVICE_CONTROL     2

//红外伴侣学习状态返回
#define STATUS_IR_CONTROLLER_SUCCESS                        0
#define STATUS_IR_CONTROLLER_UNKNOW_ERROR                   1
#define STATUS_IR_CONTROLLER_APPLIANCE_NOT_EXSIT            2
#define STATUS_IR_CONTROLLER_ORDER_IS_FULL                  3
#define STATUS_IR_CONTROLLER_LEARNING                       4
#define STATUS_IR_CONTROLLER_IS_BUSY                        5
#define STATUS_IR_CONTROLLER_CTRL_TIMEOUT                   6
#define STATUS_IR_CONTROLLER_TIMEOUT_NOT_RECEIVE_IRORDER    7
#define STATUS_IR_CONTROLLER_CMD_FORMAT_ERROR               8
#define STATUS_IR_CONTROLLER_IRORDER_NOT_LEARN              9
#define STATUS_IR_CONTROLLER_IRORDER_IS_EXSIT               10
#define STATUS_IR_CONTROLLER_TURN_ON_POWER_FIRST            12

//家电指令操作类型
#define TYPE_APPLIANCE_LEARN_ORDER  1
#define TYPE_APPLIANCE_DELETE_ORDER 2

//家电指令ID

//空调指令
#define ORDER_ID_KT_POWER                   0x00
#define ORDER_ID_KT_TEMPER_INCREASE         0x01
#define ORDER_ID_KT_TEMPER_DECREASE         0x02
#define ORDER_ID_KT_MODE_HOT                0x03
#define ORDER_ID_KT_MODE_COOL               0x04
#define ORDER_ID_KT_CUSTOM_1                0x05
#define ORDER_ID_KT_CUSTOM_2                0x06


//DVD指令
#define ORDER_ID_DVD_POWER              0x00
#define ORDER_ID_DVD_MUTE               0x01
#define ORDER_ID_DVD_VOLUMN_INCREASE    0x02
#define ORDER_ID_DVD_VOLUMN_DECREASE    0x03
#define ORDER_ID_DVD_VOICECHANNEL       0x04
#define ORDER_ID_DVD_PLAY               0x05
#define ORDER_ID_DVD_STOP               0x06
#define ORDER_ID_DVD_FORWARD            0x07
#define ORDER_ID_DVD_NEXT               0x08
#define ORDER_ID_DVD_OPEN               0x09
#define ORDER_ID_DVD_PREVIOUS_MUSIC     0x0A
#define ORDER_ID_DVD_NEXT_MUSIC         0x0B

//机顶盒指令
#define ORDER_ID_TV_POWER               0x00
#define ORDER_ID_TV_VOLUMN_INCREASE     0x01
#define ORDER_ID_TV_VOLUMN_DECREASE     0x02
#define ORDER_ID_TV_AV                  0x03
#define ORDER_ID_TVBOX_POWER            0x04
#define ORDER_ID_TVBOX_MUTE             0x05
#define ORDER_ID_TVBOX_UP               0x06
#define ORDER_ID_TVBOX_DOWN             0x07
#define ORDER_ID_TVBOX_LEFT             0x08
#define ORDER_ID_TVBOX_RIGHT            0x09
#define ORDER_ID_TVBOX_OK               0x0A
#define ORDER_ID_TVBOX_MENU             0x0B
#define ORDER_ID_TVBOX_BACK             0x0C
#define ORDER_ID_TVBOX_RETURN           0x0D
#define ORDER_ID_TVBOX_PREVIOUS_PAGE    0x0E
#define ORDER_ID_TVBOX_NEXT_PAGE        0x0F
#define ORDER_ID_TVBOX_CHANNEL          0x10
#define ORDER_ID_TVBOX_NUM_0            0x11
#define ORDER_ID_TVBOX_NUM_1            0x12
#define ORDER_ID_TVBOX_NUM_2            0x13
#define ORDER_ID_TVBOX_NUM_3            0x14
#define ORDER_ID_TVBOX_NUM_4            0x15
#define ORDER_ID_TVBOX_NUM_5            0x16
#define ORDER_ID_TVBOX_NUM_6            0x17
#define ORDER_ID_TVBOX_NUM_7            0x18
#define ORDER_ID_TVBOX_NUM_8            0x19
#define ORDER_ID_TVBOX_NUM_9            0x1A

//背景音乐指令
#define ORDER_ID_MUSIC_POWER                0x00
#define ORDER_ID_MUSIC_MUTE                 0x01
#define ORDER_ID_MUSIC_UP                   0x02
#define ORDER_ID_MUSIC_DOWN                 0x03
#define ORDER_ID_MUSIC_LEFT                 0x04
#define ORDER_ID_MUSIC_RIGHT                0x05
#define ORDER_ID_MUSIC_OK                   0x06
#define ORDER_ID_MUSIC_VOLUMN_INCREASE      0x07
#define ORDER_ID_MUSIC_VOLUMN_DECREASE      0x08
#define ORDER_ID_MUSIC_PREVIOUS_MUSIC       0x09
#define ORDER_ID_MUSIC_NEXT_MUSIC           0x0A
#define ORDER_ID_MUSIC_MODE_FM              0x0B
#define ORDER_ID_MUSIC_MODE_MUSIC           0x0C
#define ORDER_ID_MUSIC_HOME                 0x0D
#define ORDER_ID_MUSIC_BACK                 0x0E

//投影仪指令
#define ORDER_ID_TOUYIN_POWER   0x00

//其他家电指令
#define ORDER_ID_OTHER_POWER      0x00
#define ORDER_ID_OTHER_NUM_1      0x01
#define ORDER_ID_OTHER_NUM_2      0x02
#define ORDER_ID_OTHER_NUM_3      0x03
#define ORDER_ID_OTHER_NUM_4      0x04
#define ORDER_ID_OTHER_NUM_5      0x05
#define ORDER_ID_OTHER_NUM_6      0x06




#endif
