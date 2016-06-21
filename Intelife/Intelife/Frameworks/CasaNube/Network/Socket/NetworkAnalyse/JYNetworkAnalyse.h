//
//  JYNetworkAnalyse.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-5-22.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

//网关通信指令
#define GATEWAY_CONNECT_STATUS          0x01    //网关连接状态
#define REQUEST_DOWNLOAD                0x02    //请求下载数据
#define START_DOWNLOAD                  0x03    //开始下载
#define FINISH_DOWNLOAD                 0x04    //结束下载
#define DOWNLOAD_DEVICE_INFO            0x05    //下载设备信息
#define DOWNLOAD_SCENE_INFO             0x06    //下载场景信息
#define DOWNLOAD_MONITOR_CHANNEL_INFO   0x07    //下载监控通道信息
#define DOWNLOAD_ELECTRONIC_INFO        0x08    //下载家电信息
#define DOWNLOAD_SENSOR_INFO            0x09    //下载传感器信息
#define DOWNLOAD_SECURITY_INFO          0x0A    //下载安防信息
#define DOWNLOAD_TIMER_INFO             0x0B    //下载定时器信息
#define DOWNLOAD_ROOM_INFO              0x0C    //下载房间信息
#define DOWNLOAD_FLOOR_INFO             0x0D    //下载楼层信息
#define DOWNLOAD_USER_INFO              0x0E    //下载用户信息
#define DOWNLOAD_MONITOR_NETWORK_INFO   0x0F    //下载监控网络信息
#define DOWNLOAD_PUSH_TAG               0x10    //下载推送Tag信息
#define DOWNLOAD_NEW_MONITOR_INFO       0x12    //下载新监控信息
#define RECEIVE_SOCKET_ELECTRONIC_DATA  0x21    //下载智能插座电量信息
#define RECEIVE_DEVICE_STATUS           0x22    //收到设备状态数据
#define RECEIVE_TIMER_STATUS            0x23    //收到定时器状态数据
#define RECEIVE_KT_STATUS               0x27    //收到空调状态数据
#define RECEIVE_CONNECT_FAILD           0x2A    //收到连接失败数据
#define RECEIVE_SECURITY_STATUS         0x31    //收到安防状态数据
#define RECEIVE_READ_SECURITY_STATUS_ACK 0x32    //收到安防状态应答数据
#define RECEIVE_ALARM_INFO              0x33    //收到报警信息
#define RECEIVE_DISALARM_INFO           0x34    //收到解除报警数据
#define RECEIVE_PASSWORD_CONFIRM        0x35    //收到密码确认数据
#define RECEIVE_SECURITY_ARMING         0x55    //收到单个设备布防状态数据
#define RECEIVE_READ_ALARM_MESSAGE      0x58    //收到读取的报警信息
#define RECEIVE_ADD_APPLIANCE           0x59    //收到添加家电状态
#define RECEIVE_GET_APPLIANCE_LIST          0x5A    //获取家电列表
#define RECEIVE_LEARN_APPLIANCE_ORDER       0x5B    //学习一条家电指令
#define RECEIVE_DELETE_APPLIANCE_ORDER      0x5C    //删除一条家电指令
#define RECEIVE_DELETE_APPLIANCE            0x5D    //删除家电
#define RECEIVE_GET_APPLIANCE_LEARNED_ORDER 0x5E    //获取家电已学习指令
#define RECEIVE_APPLIANCE_ORDER_CONTROL_STATUS 0x5F //家电指令控制状态
#define RECEIVE_HEART_BEAT_DATA         0xA0        //收到心跳包数据

#define SECURITY_STATUS_DISARMING       1
#define RECONNECT_TIMES         5   //重连次数

#define STATUS_DOWNLOAD_NORMAL   0
#define STATUS_DOWNLOAD_START    1
#define STATUS_DOWNLOAD_FINISH   2

#define ALARM_VOICE_SPEED   3

#define SYSTEM_LANGUAGES_CHINESE    0
#define SYSTEM_LANGUAGES_OTHER      1

#define P2P_CONNECT_TIMEOUT     5       //P2P连接超时时间

@class GCDAsyncUdpSocket;
@class TCPClient;

@interface JYNetworkAnalyse : NSObject
{
    id theDelegate;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(JYNetworkAnalyse);

@property (strong, nonatomic) GCDAsyncUdpSocket *mUdpClient;
@property (strong, nonatomic) TCPClient *mTCPClient;
@property (strong, nonatomic) NSMutableArray *gatewayReceiveArray;
@property (strong, nonatomic) NSMutableArray *serverReceiveArray;
@property (strong, nonatomic) NSMutableArray *serverOrderSendList;
@property (strong, nonatomic) NSMutableArray *gatewayOrderSendList;
@property (strong, nonatomic) NSMutableArray *orderNumList;
@property (strong, nonatomic) NSTimer *gatewayHeartBeatTimer;
@property (strong, nonatomic) NSTimer *serverHeartBeatTimer;
@property (strong, nonatomic) NSTimer *checkHeartBeatTimer;
@property (strong, nonatomic) NSTimer *reConnectTimer;
@property (strong, nonatomic) NSTimer *tcpConnectTimeOutTimer;
@property (strong, nonatomic) NSTimer *changeDownloadStatusTimer;
@property (strong, nonatomic) NSString *requestState;
@property (nonatomic) BOOL isDownloadMode;
@property (nonatomic) BOOL isRepeatData;
//@property (nonatomic) BOOL isAllowedConnection;
@property (nonatomic) int functionMode;
@property (nonatomic) UInt8 serverUdpOrderID;
@property (nonatomic) UInt8 serverTcpOrderID;
@property (nonatomic) UInt8 gatewayOrderID;


- (void)initNetworkWithDelegate:(id)delegate;   //初始化网络
- (void)setDelegate:(id)delegate;
- (void)initUdpConnection;                      //初始化UDP连接
- (void)closeUdpConnect;                        //关闭UDP连接
- (void)sendToNetWithUdpData:(NSString *)udpSendData withHost:(NSString *)host withPort:(UInt16)port;
- (void)sendToNetWithUdpBroadcast:(NSString *)udpSendData;      //发送UDP广播数据
- (void)initTcpConnection;                      //初始化TCP连接
- (void)creatTcpConnect:(NSString *)connectIP port:(UInt16)connectPort;     //创建TCP连接
- (void)closeTcpConnect;
- (void)sendToNetWithTcpData:(NSString *)tcpSendData;                       //发送TCP数据
- (void)sendToServerWithUdpData:(NSString *)stringData;                     //发送服务器UDP数据
- (void)sendToServerWithTransitData:(NSString *)stringData;                 //发送中转数据
- (void)sendToServerWithHeartBeatData;
- (void)sendAckData:(int)type withCommunicationType:(NSString *)communicationType;  //发送网关应答
- (void)sendServerAckData:(int)cmd withCommunicationType:(NSString *)communicationType; //发送服务器应答
- (void)sendTransitAckData:(NSString *)ackdata; //发送中转应答
- (void)clearResendBuffer;                      //清除重发缓冲区
- (void)sendDownloadData:(int)mode;
- (void)startDownload;
- (void)sendToGatewayWithUdpData:(NSString *)stringData withHost:(NSString *)host withPort:(UInt16)port;//发送网关UDP数据
- (void)sendToGatewayWithUdpBroadcast:(NSString *)stringData;
- (void)sendToGatewayWithTcpData:(NSString *)stringData;
- (void)sendToServerWithTcpData:(NSString *)stringData;
- (void)sendToNetWithData:(NSString *)data withCommunicationType:(NSString *)communicationType;
- (void)sendToNetWithData:(NSString *)data withCommunicationMode:(int)commMode;
- (void)startGatewayHeartBeatDataTimer;
- (void)stopGatewayHeartBeatDataTimer;
- (void)stopGatewayHeartBeatCheckTimer;
- (void)startServerHeartBeatDataTimer;
- (void)stopServerHeartBeatDataTimer;
- (NSString *)translateDataFormat:(NSString *)stringData;
- (NSMutableString *)addCommunicationTypeToData:(NSString *)stringData withCommunicationType:(NSString *)communicationType;


@end


@interface JYNetworkAnalyse (JYNetworkAnalyseDelegate)
- (void) jyReceiveServerData:(NSDictionary *)serverData;
- (void) jyReceiveGatewayData:(NSDictionary *)gatewayData;
- (void)jyDidTcpConnectToHost;
- (void)jyDidTcpDisconnectFromHost;
- (void)jyDidUdpDisconnectFromHost;
@end
