//
//  JYNetworkAnalyse.m
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-5-22.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import "JYNetworkAnalyse.h"
#import "GCDAsyncUdpSocket.h"
#import "TCPClient.h"
#import "Reachability.h"
#import "SendOrderModel.h"
#import "CommonConfig.h"


#define CURRENT_TIME    [[NSDate date] timeIntervalSince1970]*1000
#define RESEND_TIME     2000

#define GATEWAY_HEARTBEART_PERIOD       5
#define SERVER_HEARTBEART_PERIOD        10

@implementation JYNetworkAnalyse
@synthesize mUdpClient, mTCPClient;
@synthesize gatewayReceiveArray, serverReceiveArray;
@synthesize gatewayOrderSendList, serverOrderSendList, orderNumList;
@synthesize gatewayOrderID, serverTcpOrderID, serverUdpOrderID;
@synthesize gatewayHeartBeatTimer, serverHeartBeatTimer, checkHeartBeatTimer, reConnectTimer, tcpConnectTimeOutTimer, changeDownloadStatusTimer;
@synthesize requestState;
@synthesize isRepeatData, isDownloadMode;
@synthesize functionMode;

SYNTHESIZE_SINGLETON_FOR_CLASS(JYNetworkAnalyse);

- (id)init
{
    if((self = [super init]))
    {
        [self initData];
    }
    
    return self;
}

- (void)initData
{
    gatewayOrderID = 0;
    serverTcpOrderID = 0;
    serverUdpOrderID = 0;
    functionMode = FUNCTION_LOGIN_CONNECTTION;
    self.serverOrderSendList = [[NSMutableArray alloc] init];
    self.gatewayOrderSendList = [[NSMutableArray alloc] init];
    self.serverReceiveArray = [[NSMutableArray alloc] init];
    self.gatewayReceiveArray = [[NSMutableArray alloc] init];
    self.orderNumList = [[NSMutableArray alloc] init];
    [self startResendThread];
    [self startReachabilityCheck];
}

#pragma mark - Delegate

- (void)setDelegate:(id)delegate
{
    theDelegate = delegate;
}

- (void)initNetworkWithDelegate:(id)delegate
{
    [self initUdpConnection];  //需要使用UDP通信时要初始化
    [self initTcpConnection];
    [self setDelegate:delegate];
}

- (void)startReachabilityCheck
{
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    Reachability *hostReach = [[Reachability reachabilityWithHostName:@"www.google.com"] retain];
    [hostReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (phoneNetworkStatus == STATUS_NOT_REACHABLE && status != NotReachable)
    {
        //        [self initUdpConnection];
    }
    if ((phoneNetworkStatus != STATUS_UNKNOW_NETWORK) && (fsmApplicationStatus != FSM_APPLICATION_WILL_RESIGN_ACTIVE))
    {
        NSLog(@"检测到网络状态改变，开始重新登录连接。。。");
        [JY_P2P_INSTANCE p2pReloginToServer];
    }
    if (status == ReachableViaWiFi)
    {
        NSLog(@"WiFi连接");
        phoneNetworkStatus = STATUS_WIFI_NETWORK;
    }
    else if (status == ReachableViaWWAN)
    {
        NSLog(@"蜂窝网络连接");
        phoneNetworkStatus = STATUS_WWAN_NETWORK;
    }
    else if (status == NotReachable)
    {
        NSLog(@"网络未连接！！！");
        phoneNetworkStatus = STATUS_NOT_REACHABLE;
    }
}

#pragma mark - UDP Connect

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
    //    NSLog(@"%s %d", __FUNCTION__, __LINE__);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    NSLog(@"UDP_SendError:%@",error);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    //声明一个gbk编码类型
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //使用如下方法 将获取到的数据按照gbkEncoding的方式进行编码，结果将是正常的汉字
    NSString *udpReceiveData = [[[NSString alloc] initWithData:data encoding:gbkEncoding] autorelease];
    NSString *logString = [self translateDataFormat:udpReceiveData];
    NSLog(@"(UDP)接收:%@",logString);
//    NSLog(@"IP:%@", host);
    [self updataResendListWithOrderString:udpReceiveData];
    [self jyReceiveUdpData:udpReceiveData];
//    if ([theDelegate respondsToSelector:@selector(jyReceiveUdpData:)])
//    {
//        [theDelegate jyReceiveUdpData:udpReceiveData];
//    }
}

/**
 * Called if an error occurs while trying to receive a requested datagram.
 * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
 **/
- (void)onUdpSocket:(GCDAsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    NSLog(@"UDP_ReceiveError:%@",error);
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    NSLog(@"UDP-断开连接");
    NSLog(@"UDP_CloseError:%@",error);
    if ([theDelegate respondsToSelector:@selector(jyDidUdpDisconnectFromHost)])
    {
        [theDelegate jyDidUdpDisconnectFromHost];
    }
}

- (void)initUdpConnection
{
    if (self.mUdpClient != nil)
    {
        [mUdpClient close];
        [mUdpClient release];
        self.mUdpClient = nil;
    }
    self.mUdpClient = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![mUdpClient bindToPort:UDP_CLIENT_PORT error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    
    if (![mUdpClient beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    //    [mUdpClient receiveWithTimeout:-1 tag:0];
    
    NSLog(@"UDP-Ready");
}

- (void)closeUdpConnect
{
    if (self.mUdpClient)
    {
        [self.mUdpClient close];
    }
}

- (void)sendToNetWithUdpData:(NSString *)udpSendData withHost:(NSString *)host withPort:(UInt16)port
{
    if (self.mUdpClient)
    {
        NSLog(@"iP：%@",host);
        NSMutableString *udpSendString = [NSMutableString stringWithString:udpSendData];
        [udpSendString appendString:FRAME_END_STRING];
        NSString *logString = [self translateDataFormat:udpSendString];
        NSLog(@"(UDP)发送:%@",logString);
        //声明一个gbk编码类型
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *data = [udpSendString  dataUsingEncoding:gbkEncoding];//转换数据类型
        //开始发送
        [self.mUdpClient sendData: data
                           toHost: host
                             port: port
                      withTimeout: -1   //将这个时间改为5S，防止没网的情况导致的软件卡死现象，初始值为-1
                              tag: 0];
    }
    else
    {
        NSLog(@"UDP--指令发送失败！！！");
    }
}

- (void)sendToNetWithUdpBroadcast:(NSString *)udpSendData
{
    if (self.mUdpClient)
    {
        NSMutableString *udpSendString = [NSMutableString stringWithString:udpSendData];
        [udpSendString appendString:FRAME_END_STRING];
        NSString *logString = [self translateDataFormat:udpSendString];
        NSLog(@"(UDP广播)发送:%@",logString);
        NSData *data = [udpSendString  dataUsingEncoding:NSASCIIStringEncoding];//转换数据类型
        NSError *error = nil;
        [self.mUdpClient enableBroadcast:YES error:&error];
        //开始发送
        [self.mUdpClient sendData: data
                           toHost: UDP_BROADCAST_IP
                             port: UDP_BROADCAST_PORT
                      withTimeout: -1
                              tag: 0];
    }
    else
    {
        NSLog(@"UDP--广播指令发送失败！！！");
    }
    
}

- (void)sendToServerWithUdpData:(NSString *)stringData
{
    NSLog(@"(服务器--UDP)发送:");
    unsigned int tempCmd = 0;
    NSString *sendString = nil;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[stringData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    tempCmd = [(NSNumber *)[orderDic objectForKey:@"cmd"] intValue];
    
    if ((tempCmd & 0xFF)>>7 == 0)
    {
        tempCmd |= (++serverUdpOrderID << 8);
        [orderDic setObject:[NSNumber numberWithInt:tempCmd] forKey:@"cmd"];
        sendString = [orderDic JSONString];
        [self addOrderToServerSendListWithObject:sendString WithOrderID:(tempCmd >> 8)];
    }
    else
    {
        [orderDic setObject:[NSNumber numberWithInt:tempCmd] forKey:@"cmd"];
        sendString = [orderDic JSONString];
    }

    [self sendToNetWithUdpData:sendString withHost:SERVER_IP withPort:SERVER_PORT];
    [orderDic release];
}

- (void)sendToGatewayWithUdpData:(NSString *)stringData withHost:(NSString *)host withPort:(UInt16)port
{
    NSLog(@"(网关--UDP)发送数据:");
    NSString *sendString = nil;
    unsigned int tempType = 0;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[stringData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    if (communicationMode & MODE_P2P_CONNECT)  //加上这个避免在中转模式下也发送UDP数据
    {
        if((netConnectStatus == NET_CONNECTED || netConnectStatus == NET_CONNECTING))
        {
            if (![[orderDic allKeys] containsObject:@"ran"])
            {
                [[NSScanner scannerWithString:[orderDic objectForKey:@"type"]] scanHexInt:&tempType];
                if ((tempType&0xFFFF)>>15 == 0)
                {
                    tempType |= (++gatewayOrderID << 16);
                    [orderDic setObject:[NSString stringWithFormat:@"%x",tempType] forKey:@"type"];
                    sendString = [orderDic JSONString];
                    [self addOrderToGatewaySendListWithObject:sendString WithOrderID:(tempType >> 16)];
                }
                else
                {
                    [orderDic setObject:[NSString stringWithFormat:@"%x",tempType] forKey:@"type"];
                    sendString = [orderDic JSONString];
                }
            }
            else
            {
                tempType = [[orderDic objectForKey:@"cmd"] intValue];
                if ((tempType&0xFF)>>7 == 0)
                {
                    tempType |= (++gatewayOrderID << 8);
                    [orderDic setObject:[NSNumber numberWithInt:tempType] forKey:@"cmd"];
                    sendString = [orderDic JSONString];
                    [self addOrderToGatewaySendListWithObject:sendString WithOrderID:(tempType >> 8)];
                }
            }
            [self sendToNetWithUdpData:sendString withHost:host withPort:port];
            [orderDic release];
        }
        else
        {
            NSLog(@"%s %d", __FUNCTION__, __LINE__);
            tempType = tempType & 0xFF;
            NSLog(@"(网关UDP)-指令没有发送成功!");
            if (tempType == 0x20 || tempType == 0x24 || tempType == 0x25 || tempType == 0x26 || tempType == 0x31)
            {
                //                [self showAlertDialogWithTitle:NSLocalizedStringFromTable(@"Remind", @"InfoPlist",nil) withMsg:NSLocalizedStringFromTable(@"SendOrderFaild", @"InfoPlist",nil) withCancelBtnTitle:NSLocalizedStringFromTable(@"IGotIt", @"InfoPlist",nil) withOtherBtnTitle:nil withShowStyle:UIAlertViewStyleDefault withTag:0];
            }
        }
    }
}

- (void)sendToGatewayWithUdpBroadcast:(NSString *)stringData
{
    unsigned int tempCmd = 0;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[stringData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    tempCmd = [(NSNumber *)[orderDic objectForKey:@"cmd"] intValue];
    if ((tempCmd & 0x80) != 0x80)
    {
        tempCmd |= (++gatewayOrderID << 8);
    }
    [orderDic setObject:[NSNumber numberWithInt:tempCmd] forKey:@"cmd"];
    NSString *sendString = [orderDic JSONString];
    [self sendToNetWithUdpBroadcast:sendString];
}

#pragma mark - TCP Connect

- (void)initTcpConnection
{
    self.mTCPClient = [[TCPClient alloc] initWithDelegate:self];
    NSLog(@"TCP-Ready");
}

- (void)creatTcpConnect:(NSString *)connectIP port:(UInt16)connectPort
{
    NSLog(@"创建TCP连接！！！");
    [self closeTcpConnect];
    [self.mTCPClient connectHost:connectIP port:connectPort];
}

- (void)closeTcpConnect
{
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    if (self.mTCPClient)
    {
        NSLog(@"主动断开TCP连接！！！");
        [self.mTCPClient disconnect];
    }
}

- (void)didConnectToHost//这个函数基本就这样  暂时我不改他
{
    NSLog(@"%@",@"与主机连接");
    serverConnectStatus = NET_CONNECTED;
    [JY_P2P_INSTANCE getTcpTempLoginKey];
    if ([theDelegate respondsToSelector:@selector(jyDidTcpConnectToHost)])
    {
        [theDelegate jyDidTcpConnectToHost];
    }
}

- (void)didDisconnectFromHost
{
    NSLog(@"%@",@"与主机断开");
    if (communicationMode == MODE_TRANSIT_CONNECT || communicationMode == MODE_UNKNOW_CONNECT)
    {
        netConnectStatus = NET_UNCONNECTED;
    }
    if ([theDelegate respondsToSelector:@selector(jyDidTcpDisconnectFromHost)])
    {
        [theDelegate jyDidTcpDisconnectFromHost];
    }
}

#pragma mark - ReConnect to gateway

- (void)startReConnectTimer
{
    //    int reconnectPeriod = 0;
    if (reConnectTimer != nil)
    {
        [reConnectTimer invalidate];
        reConnectTimer = nil;
    }
    if (isAllowedConnection)
    {
        NSLog(@"启动重连...");
        loginAccountType = TYPE_LOGIN_AUTO;  //启动重连后设置为自动登陆模式
        reConnectTimer = [NSTimer scheduledTimerWithTimeInterval:P2P_RECONNECT_PERIOD target:self selector:@selector(reconnectToNetwork) userInfo:nil repeats:YES];
    }
}

- (void)stopReConnectTimer
{
    if (reConnectTimer != nil)
    {
        [reConnectTimer invalidate];
        reConnectTimer = nil;
    }
}

- (void)reconnectToNetwork
{
    static int reconnectTimes = RECONNECT_TIMES;
    if ((reconnectTimes-- > 0) && (netConnectStatus != NET_CONNECTED) && isAllowedConnection)
    {
        if (communicationMode == MODE_DNS_ADDRESS)
        {
            //            [self connectToHost:ipAddressStr port:[portStr intValue]];
        }
        else if(loginAccountType == TYPE_LOGIN_AUTO)
        {
            [JY_P2P_INSTANCE p2pReloginToServer];
        }
//        if (self.functionMode == FUNCTION_LOCAL_CONNECTTION && self.gatewayAddedList.count > 0)
//        {
//            GatewayInfoModel *gatewayInfo = [self.gatewayAddedList objectAtIndex:0];
//            [JY_P2P_INSTANCE clientTryP2PConnectWithIP:gatewayInfo.gatewayIpAddress withPort:gatewayInfo.gatewayPort];
//        }
        NSLog(@"重连网络。。。");
    }
    else if((reconnectTimes <= 0) && (netConnectStatus != NET_CONNECTED))
    {
        NSLog(@"与网关连接失败，请检查网络连接!");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAccountManageListMsg" object:nil];
        netConnectStatus = NET_UNCONNECTED;
        reconnectTimes = RECONNECT_TIMES;
        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"ConnectFailure") delayTime:SHOWTOAST_TIME atView:[CommonUtils getCurrentVC].view];
    }
    else if (netConnectStatus == NET_CONNECTED)
    {
        reconnectTimes = RECONNECT_TIMES;
    }
}

- (void)sendToNetWithTcpData:(NSString *)tcpSendData
{
    if(mTCPClient)
    {
        NSMutableString *tcpSendString = [NSMutableString stringWithString:tcpSendData];
        [tcpSendString appendString:FRAME_END_STRING];
        NSString *logString = [self translateDataFormat:tcpSendString];
        NSLog(@"(TCP)发送:%@",logString);
        [mTCPClient sendData:tcpSendString];
    }
    else
    {
        NSLog(@"TCP--指令发送失败！！!");
    }
}

- (void)receiveData:(NSData *)data
{
    //声明一个gbk编码类型
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //使用如下方法 将获取到的数据按照gbkEncoding的方式进行编码，结果将是正常的汉字
    NSMutableString *tcpReceiveData = [[[NSMutableString alloc] initWithData:data encoding:gbkEncoding] autorelease];
    NSString *logString = [self translateDataFormat:tcpReceiveData];
    NSLog(@"(TCP)接收:%@",logString);
    tcpReceiveData = [self addCommunicationTypeToData:tcpReceiveData withCommunicationType:@"TCP"];
    [tcpReceiveData appendString:FRAME_END_STRING];   //加上结束字符
    [self jyReceiveTcpData:tcpReceiveData];
}

-(void) jyReceiveTcpData: (NSString *)tcpData
{
    //    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    NSMutableString *receiveTcpData = [NSMutableString stringWithString:tcpData];
    if ([receiveTcpData hasPrefix:FRAME_START_STRING] && [receiveTcpData hasSuffix:FRAME_END_STRING])
    {
        NSRange range = [receiveTcpData rangeOfString:FRAME_END_STRING];
        if (range.length > 0)
            [receiveTcpData deleteCharactersInRange:range];
        NSMutableDictionary *receiveDic = [[NSMutableDictionary alloc] init];
        [receiveDic addEntriesFromDictionary:[receiveTcpData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
        //        receiveTcpData = [JY_NETWORK_INSTANCE addCommunicationTypeToData:receiveTcpData withCommunicationType:@"TCP"];
        [receiveTcpData appendString:FRAME_END_STRING];  //加上结束字符
        
        if ([[receiveDic allKeys] containsObject:@"cmd"])
            //        if ([tcpData containsString:@"cmd"])
        {
            //                        NSLog(@"收到服务器数据。。。");
            [self receiveServerTcpData:receiveTcpData];
        }
        else if ([[receiveDic allKeys] containsObject:@"type"])
            //        if ([tcpData containsString:@"type"])
        {
            //            NSLog(@"收到网关数据。。。");
            [self receiveGatewayUdpData:receiveTcpData];
        }
        [receiveDic release];
    }
}

- (void)receiveServerTcpData:(NSString *)receiveData
{
    NSMutableArray *tempReceiveArray = (NSMutableArray *)[receiveData componentsSeparatedByString:FRAME_END_STRING]; //从字符strData中分隔数据
    [tempReceiveArray removeObject:@""];  //移除数据中为空的对象
    for (int i = 0; i < tempReceiveArray.count; i++)
    {
        NSString *jsonString = [tempReceiveArray objectAtIndex:i];
        NSDictionary *receiveDic = [jsonString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        UInt16 cmd = 0;
        cmd = [[receiveDic objectForKey:@"cmd"] integerValue];
        //指令应答
        [JY_NETWORK_INSTANCE sendServerAckData:cmd withCommunicationType:(NSString *)[receiveDic objectForKey:@"socket"]];
        if ([[receiveDic allKeys] containsObject:@"data"])
        {
            NSString *transitData = (NSString *)[receiveDic objectForKey:@"data"];
            [JY_NETWORK_INSTANCE sendTransitAckData:transitData];  //发送中转应答数据
            transitData = [JY_NETWORK_INSTANCE addCommunicationTypeToData:transitData withCommunicationType:@"TCP"];
            [self checkValidData:transitData withDataBuff:tempReceiveArray];
        }
        else
        {
            [serverReceiveArray addObject:[tempReceiveArray objectAtIndex:i]];
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(serverDataAnalysis:) userInfo:nil repeats:NO];
        }
    }
}

-(void) jyReceiveUdpData: (NSString *)udpData
{
    //    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    NSMutableString *receiveUdpData = [NSMutableString stringWithString:udpData];
    if ([receiveUdpData hasPrefix:FRAME_START_STRING] && [receiveUdpData hasSuffix:FRAME_END_STRING])
    {
        NSRange range = [receiveUdpData rangeOfString:FRAME_END_STRING];
        if (range.length > 0)
            [receiveUdpData deleteCharactersInRange:range];
        NSMutableDictionary *receiveDic = [[NSMutableDictionary alloc] init];
        [receiveDic addEntriesFromDictionary:[receiveUdpData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
        receiveUdpData = [JY_NETWORK_INSTANCE addCommunicationTypeToData:receiveUdpData withCommunicationType:@"UDP"];
        [receiveUdpData appendString:FRAME_END_STRING];  //加上结束字符
        
        if ([[receiveDic allKeys] containsObject:@"cmd"])
        {
            //                        NSLog(@"收到服务器数据。。。");
            [self receiveServerUdpData:receiveUdpData];
        }
        else if ([[receiveDic allKeys] containsObject:@"type"])
        {
            //            NSLog(@"收到网关数据。。。");
            //            NSLog(@"%s %d", __FUNCTION__, __LINE__);
            [self receiveGatewayUdpData:receiveUdpData];
        }
        [receiveDic release];
    }
    
}

- (void)receiveServerUdpData:(NSString *)receiveData
{
    //    NSLog(@"(服务器--UDP)接收:%@",[JY_NETWORK_INSTANCE translateDataFormat:receiveData]);
    
    NSMutableArray *tempReceiveArray = (NSMutableArray *)[receiveData componentsSeparatedByString:FRAME_END_STRING]; //从字符strData中分隔数据
    [tempReceiveArray removeObject:@""];  //移除数据中为空的对象
    for (int i = 0; i < tempReceiveArray.count; i++)
    {
        NSString *serverReceiveString = [tempReceiveArray objectAtIndex:i];
        NSDictionary *serverReceiveDic = [serverReceiveString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        UInt16 cmd = 0;
        cmd = [[serverReceiveDic objectForKey:@"cmd"] integerValue];
        //指令应答
        [JY_NETWORK_INSTANCE sendServerAckData:cmd withCommunicationType:(NSString *)[serverReceiveDic objectForKey:@"socket"]];
        [serverReceiveArray addObject:[tempReceiveArray objectAtIndex:i]];
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(serverDataAnalysis:) userInfo:nil repeats:NO];
    }
}


- (void)receiveGatewayUdpData:(NSString *)downloadData
{
    //    NSLog(@"网关--接收:%@",downloadData);
    //    downloadData = [self removeSpaceAndNewline:downloadData];  //移除收到数据中的空格回车换行符
    NSMutableArray *tempReceiveArray = (NSMutableArray *)[downloadData componentsSeparatedByString:FRAME_END_STRING]; //从字符strData中分隔数据
    [tempReceiveArray removeObject:@""];  //移除数据中为空的对象
    for (int i = 0; i < tempReceiveArray.count; i++)
    {
        //NSLog(@"复制下载数据");
        //            [downloadArray addObject:[tempDownloadArray objectAtIndex:i]];
        NSString *receiveData = [tempReceiveArray objectAtIndex:i];
        NSDictionary *ackDic = [receiveData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        unsigned int typeInt = 0;
        unsigned int orderNum = 0;
        //            unsigned int tempOrderNum = 0;
        //解析hex字符串并转换成int类型
        [[NSScanner scannerWithString:[ackDic objectForKey:@"type"]] scanHexInt:&typeInt];
        //指令应答
        [JY_NETWORK_INSTANCE sendAckData:typeInt withCommunicationType:(NSString *)[ackDic objectForKey:@"socket"]];
        orderNum = typeInt >> 16;
        //            typeInt = typeInt & 0xFF;
        //        [self updataGatewaySendListWithOrderID:orderNum];
        [self checkValidData:receiveData withDataBuff:tempReceiveArray];
    }
}

- (void)checkValidData:(NSString *)receiveData withDataBuff:(NSMutableArray *)tempDataArray
{
    unsigned int typeInt = 0;
    unsigned int orderNum = 0;
    unsigned int ackBit = 0;
    unsigned int tempOrderNum = 0;
    unsigned int downloadStatus = 0;
    NSDictionary *ackDic = [receiveData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    //解析hex字符串并转换成int类型
    [[NSScanner scannerWithString:[ackDic objectForKey:@"type"]] scanHexInt:&typeInt];
    ackBit = typeInt & 0xFFFF;
    orderNum = typeInt >> 16;
    typeInt = typeInt & 0xFF;
    if (typeInt == FINISH_DOWNLOAD)
    {
        NSLog(@"收到结束下载");
        downloadStatus = STATUS_DOWNLOAD_FINISH;
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadControlDeviceListMsg" object:nil];
    }
    else if (typeInt == START_DOWNLOAD)
    {
        downloadStatus = STATUS_DOWNLOAD_START;
    }
    else if (typeInt == REQUEST_DOWNLOAD)
    {
        isRepeatData = NO;
        //        [gatewayReceiveArray removeAllObjects];
        [orderNumList removeAllObjects];
        //        loginAccountType = TYPE_LOGIN_AUTO;
        NSLog(@"收到请求下载应答");
    }
    if (ackBit & 0x8000)
    {
        //        NSLog(@"应答数据，不记录指令ID直接解析");
        [gatewayReceiveArray addObject:receiveData];
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gatewayDataAnalysis:) userInfo:nil repeats:NO];
    }
    else
    {
        if (orderNumList.count == 0)
        {
            [orderNumList addObject:[NSString stringWithFormat:@"%x",orderNum]];
            [gatewayReceiveArray addObject:receiveData];
            NSLog(@"启动解析定时器");
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gatewayDataAnalysis:) userInfo:nil repeats:NO];
        }
        else
        {
            for (int j = 0; j < orderNumList.count; j++)
            {
                [[NSScanner scannerWithString:[orderNumList objectAtIndex:j]] scanHexInt:&tempOrderNum];
                if (tempOrderNum == orderNum)
                {
                    NSLog(@"收到重复数据");
                    isRepeatData = YES;
                    break;
                }
                else
                {
                    isRepeatData = NO;
                }
            }
            if (!isRepeatData)
            {
                //            NSLog(@"收到不同数据");
                if (isDownloadMode && (typeInt >= START_DOWNLOAD && typeInt <= DOWNLOAD_PUSH_TAG))
                {
                    [orderNumList addObject:[NSString stringWithFormat:@"%x",orderNum]];
                    [gatewayReceiveArray addObject:receiveData];
                }
                else
                {
                    if (!isDownloadMode) //解决下载数据10S内的设备状态不会实时更新
                    {
                        [orderNumList removeAllObjects];
                    }
                    [orderNumList addObject:[NSString stringWithFormat:@"%x",orderNum]];
                    [gatewayReceiveArray addObject:receiveData];
                    //                NSLog(@"正常模式-->启动解析定时器。。。");
                    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gatewayDataAnalysis:) userInfo:nil repeats:NO];
                }
            }
            if (typeInt == FINISH_DOWNLOAD)
            {
                NSLog(@"下载模式-->启动解析定时器。。。");
                [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gatewayDataAnalysis:) userInfo:nil repeats:NO];
            }
        }
    }
}

- (void)serverDataAnalysis:(NSTimer *)timer
{
    if (serverReceiveArray.count > 0)
    {
        NSString *jsonString = [serverReceiveArray objectAtIndex:0];
        NSDictionary *ackDic = [jsonString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        UInt16 cmd = 0;
        UInt16 returnValue = 0;
        NSString *communicationType = nil;
        cmd = [[ackDic objectForKey:@"cmd"] integerValue];
        returnValue = [[ackDic objectForKey:@"ret"] integerValue];
        communicationType = (NSString *)[ackDic objectForKey:@"socket"];
        cmd = cmd & 0x7F;
        switch (cmd)
        {
            case CLIENT_GET_TEMP_KEY:
                commonKey = [NSMutableString stringWithString:DEFAULT_COMMON_KEY];
                tempKey = [ackDic objectForKey:@"key"];
                [commonKey insertString:tempKey atIndex:1];
                
                if ([communicationType isEqualToString:@"TCP"])
                {
                    NSLog(@"TCP--实际密钥：%@",commonKey);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTempKeyMsg" object:GET_TCP_TEMP_KEY_SUCCESS];
                }
                else if ([communicationType isEqualToString:@"UDP"])
                {
                    NSLog(@"UDP--实际密钥：%@",commonKey);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTempKeyMsg" object:GET_UDP_TEMP_KEY_SUCCESS];
                }
                [JY_P2P_INSTANCE loginToServerWithCommunicationType:communicationType];
                break;
            case CLIENT_REGISTER_ACCOUNT:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        NSLog(@"用户名注册成功");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"RegistSuccess") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_USERNAME_EXIST:
                        NSLog(@"用户名已存在");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountAlreadyExist") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_USERNAME_FORMAT_ERROR:
                        NSLog(@"用户名格式错误");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountFormatError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_PASSWORD_FORMAT_ERROR:
                        NSLog(@"密码格式错误");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"PasswordFormatError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_EMAIL_FORMAT_ERROR:
                        NSLog(@"邮箱格式错误");
                        break;
                        
                    default:
                        break;
                }
                break;
            case CLIENT_LOGIN_ACCOUNT:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        if ([communicationType isEqualToString:@"TCP"])
                        {
                            NSLog(@"TCP--账户登陆成功");
                            transitLoginStatus = LOGIN_SUCCESS;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountLoginMsg" object:TCP_LOGIN_ACCOUNT_SUCCESS];
                            if (netConnectStatus != NET_CONNECTED)
                            {
                                [JY_P2P_INSTANCE clientDataTransit:gatewayMac];  //进行中转连接
                            }
                        }
                        else if ([communicationType isEqualToString:@"UDP"])
                        {
                            NSLog(@"UDP--账户登陆成功");
                            p2pLoginStatus = LOGIN_SUCCESS;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountLoginMsg" object:UDP_LOGIN_ACCOUNT_SUCCESS];
                            if (netConnectStatus != NET_CONNECTED)
                            {
                                [JY_P2P_INSTANCE clientStartP2PConnectWithMac:gatewayMac];
                            }
                        }
                        break;
                    case RETURN_PASSWORD_ERROR:
                        NSLog(@"密码错误");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"PasswordError") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_USER_NOT_EXIST:
                        NSLog(@"用户名不存在");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"AccountNotExist") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_CLIENT_RELOGIN:
                        NSLog(@"重复登录");
                        break;
                        
                    default:
                        break;
                }
                break;
            case CLIENT_ADD_DEVICE:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        NSLog(@"添加设备成功");
                        break;
                    case RETURN_DEVICE_NOT_EXIST:
                        NSLog(@"此网关不存在");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"GatewayNotExist") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_DEVICE_EXIST:
                        NSLog(@"此网关已添加");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"GatewayAlreadyExist") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    default:
                        break;
                }
                break;
            case CLIENT_DELETE_DEVICE:
                break;
            case CLIENT_START_P2P_CONNECT:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        break;
                    case RETURN_DEVICE_UNLOGIN:
                        NSLog(@"UDP--网关未登录");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"GatewayNotLogin") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_CLIENT_UNLOGIN:
                        NSLog(@"客户端未登录");
//                        [JY_PROGRESS_HUD ShowTips:@"客户端未登录" delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    case RETURN_LOCAL_LOGIN:
                        NSLog(@"请尝试局域网连接");
                        gatewayIPAddress = [ackDic objectForKey:@"ip"];
                        gatewayPort = [((NSNumber *)[ackDic objectForKey:@"port"]) intValue];
                        [gatewayIPAddress retain];
                        [JY_P2P_INSTANCE clientTryP2PConnectWithIP:gatewayIPAddress withPort:gatewayPort];
                        //checkP2PStatusTimer = [NSTimer scheduledTimerWithTimeInterval:P2P_CONNECT_TIMEOUT target:self selector:@selector(noticeP2PConnectFailed) userInfo:nil repeats:NO];
                        break;
                        
                    default:
                        break;
                }
                break;
            case DEVICE_THROUGH_CHANNEL:
                NSLog(@"收到网关打洞帧");
                break;
            case NOTICE_CLIENT_P2P_CONNECT:
                NSLog(@"收到尝试P2P连接");
                gatewayIPAddress = [ackDic objectForKey:@"ip"];
                gatewayPort = [((NSNumber *)[ackDic objectForKey:@"port"]) intValue];
                [gatewayIPAddress retain];
                //[JY_P2P_INSTANCE clientTryP2PConnectWithIP:gatewayIPAddress withPort:gatewayPort];
                //checkP2PStatusTimer = [NSTimer scheduledTimerWithTimeInterval:P2P_CONNECT_TIMEOUT target:self selector:@selector(noticeP2PConnectFailed) userInfo:nil repeats:NO];
                break;
            case CLIENT_TRY_P2P_CONNECT:
                NSLog(@"收到网关成功应答");
                if (self.functionMode == FUNCTION_LOGIN_CONNECTTION)
                    [JY_P2P_INSTANCE noticeP2PConnectSuccess];
                [JY_P2P_INSTANCE requestConnectWithCommunicationType:communicationType];   //发送请求连接指令
                //                [JY_NETWORK_INSTANCE stopServerHeartBeatDataTimer];  //停止向服务器发送的心跳包
                //                if (checkP2PStatusTimer != nil && communicationMode != MODE_TRANSIT_CONNECT)
                //                {
                //                    [checkP2PStatusTimer invalidate];  //此处偶尔会出现闪退
                //                    checkP2PStatusTimer = nil;
                //                }
                break;
            case NOTICE_P2P_CONNECT_SUCCESS:
                break;
            case CLIENT_TRANSIT_CONNECT:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        NSLog(@"开始中转连接");
    //                    tcpConnectTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:P2P_CONNECT_TIMEOUT target:self selector:@selector(connectTimeOut) userInfo:nil repeats:NO];
                        [JY_P2P_INSTANCE requestConnectWithCommunicationType:communicationType];
                        //                [self stopServerBeatDataTimer];
                        break;
                    case RETURN_DEVICE_UNLOGIN:
                        NSLog(@"TCP--网关未登录");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"GatewayNotLogin") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        break;
                    default:
                        break;
                }
                break;
            case SERVER_HEART_BEAT:
                switch (returnValue)
                {
                    case RETURN_DEVICE_UNLOGIN:
                        break;
                    case RETURN_CLIENT_UNLOGIN:
                        break;
                    case RETURN_NOT_SUPPORT:
                        break;
                        
                    default:
                        break;
                }
                break;
            case GATEWAY_CONNECT_CLOSE:
                NSLog(@"网关与服务器断开连接！！！");
                break;
            case GATEWAY_CONNECT_AGAIN:
                NSLog(@"网关与服务器恢复连接！！！");
                break;
            case EDIT_ACCOUNT_PASSWORD:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        NSLog(@"修改密码成功");
//                        [JY_PROGRESS_HUD ShowTips:LocalizedString(@"EditPasswordSuccess") delayTime:SHOWTOAST_TIME atView:CURRENT_VIEW];
                        [JY_P2P_INSTANCE clientLogoutAccount];
                        break;
                    case RETURN_PASSWORD_ERROR:
                        NSLog(@"密码错误");
                        break;
                        
                    default:
                        break;
                }
                break;
            case FIND_ACCOUNT_PASSWORD:
                switch (returnValue)
                {
                    case RETURN_SUCCESS:
                        NSLog(@"找回密码成功");
                        break;
                    case RETURN_USER_NOT_EXIST:
                        NSLog(@"用户名不存在");
                        break;
                        
                    default:
                        break;
                }
                break;
            case CLIENT_LOGOUT_ACCOUNT:
                NSLog(@"注销成功");
                loginAccountType = TYPE_LOGIN_ACTIVE;
                netConnectStatus = NET_UNCONNECTED;
                //[self clearAllDataList];
                [JY_NETWORK_INSTANCE clearResendBuffer];
                [JY_NETWORK_INSTANCE closeTcpConnect];
                [JY_NETWORK_INSTANCE closeUdpConnect];
                [JY_NETWORK_INSTANCE initUdpConnection];//注销后重新创建socket防止收到之前连接的网关数据
                [JY_NETWORK_INSTANCE stopGatewayHeartBeatDataTimer];
                [JY_NETWORK_INSTANCE stopServerHeartBeatDataTimer];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AccountLoginMsg" object:LOGOUT_ACCOUNT_SUCCESS];
//                [self stopReConnectTimer];
                break;
            case GATEWAY_MAC_ADDRESS:
                NSLog(@"收到网关MAC地址");
                break;
            case CLIENT_GET_GATEWAY_MAC:
                NSLog(@"收到网关P2P ID");
                break;
                
            default:
                break;
        }
        if ([theDelegate respondsToSelector:@selector(jyReceiveServerData:)])
        {
            [theDelegate jyReceiveServerData:ackDic];
        }
        [serverReceiveArray removeObjectAtIndex:0];
        
    }
    
    if (serverReceiveArray.count > 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(serverDataAnalysis:) userInfo:nil repeats:NO];
    }
}

- (void)noticeP2PConnectFailed
{
    [JY_P2P_INSTANCE noticeP2PConnectFailed];
}

- (void)connectTimeOut
{
    [JY_PROGRESS_HUD ShowTips:LocalizedString(@"ConnectTimeOut") delayTime:SHOWTOAST_TIME atView:[CommonUtils getCurrentVC].view];
}

- (void)gatewayDataAnalysis:(NSTimer *)timer
{
    //NSString *cmdString;
    NSString *nameString;
    //    NSString *alarmStatusMsg;
    if (gatewayReceiveArray.count > 0)
    {
        NSString *jsonString = [gatewayReceiveArray objectAtIndex:0];
        NSDictionary *nsDic = [jsonString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        NSString *type = (NSString *)[nsDic objectForKey:@"type"];
        NSString *communicationType = [nsDic objectForKey:@"socket"];
        //NSArray *arrayResult = [nsDic objectForKey:@"name"];
        unsigned int typeInt = 0;
        //解析hex字符串并转换成int类型
        [[NSScanner scannerWithString:type] scanHexInt:&typeInt];
        typeInt = typeInt & 0xFF;
        switch (typeInt)
        {
            case GATEWAY_CONNECT_STATUS:
                nameString = [nsDic objectForKey:@"name"];
                requestState = [nsDic objectForKey:@"CMD"];
                if ([requestState isEqualToString:@"0"])
                {
                    NSLog(@"网关拒绝连接!!!");
                    isAllowedConnection = NO;
                    netConnectStatus = NET_UNCONNECTED;
                    NSMutableDictionary *otherConfigDic = [[NSMutableDictionary alloc] init];
                    [otherConfigDic setObject:@"0" forKey:@"connectAllow"];
                    [JY_DATABASE_INSTANCE updataItemToTable:@"OtherConfig" withValues:otherConfigDic withWhere:@"_id=?" withArgs:@"1"];
                    [otherConfigDic release];
                }
                else if([requestState isEqualToString:@"1"] || [requestState isEqualToString:@"3"])
                {
                    netConnectStatus = NET_CONNECTED;
                    isAllowedConnection = YES;
                    if ([requestState isEqualToString:@"3"])
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"MainHomeAlarmFlashMsg" object:[NSNumber numberWithInt:1]];
                    }
                    if ([communicationType isEqualToString:@"TCP"])
                    {
                        NSLog(@"TCP--网关允许连接!!!");
                        if (tcpConnectTimeOutTimer != nil)
                        {
                            [tcpConnectTimeOutTimer invalidate];
                            tcpConnectTimeOutTimer = nil;
                        }
                    }
                    else if(communicationMode & MODE_P2P_CONNECT)
                    {
                        NSLog(@"UDP--网关允许连接!!!");
                        communicationMode = MODE_P2P_CONNECT;
                        [JY_P2P_INSTANCE clientCloseTransitConnect]; //P2P连接成功，断开中转连接
                    }
                    NSMutableDictionary *otherConfigDic = [[NSMutableDictionary alloc] init];
                    [otherConfigDic setObject:@"1" forKey:@"connectAllow"];
                    [JY_DATABASE_INSTANCE updataItemToTable:@"OtherConfig" withValues:otherConfigDic withWhere:@"_id=?" withArgs:@"1"];
                    [otherConfigDic release];
                    if (self.functionMode != FUNCTION_LOCAL_CONNECTTION)
                    {
                        [JY_NETWORK_INSTANCE startServerHeartBeatDataTimer];
                    }
                    [JY_NETWORK_INSTANCE startGatewayHeartBeatDataTimer];
                    [self startReConnectTimer];
                }
                break;
            case START_DOWNLOAD:
                NSLog(@"开始下载。。。");
                break;
            case FINISH_DOWNLOAD:
                NSLog(@"结束下载。。。");
                self.changeDownloadStatusTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(changeDownloadStatus) userInfo:nil repeats:NO]; //启动重连定时器
                break;
            case DOWNLOAD_DEVICE_INFO:
                NSLog(@"下载设备信息数据。。。");
                break;
            case DOWNLOAD_SCENE_INFO:
                NSLog(@"下载场景信息数据。。。");
                break;
            case DOWNLOAD_MONITOR_CHANNEL_INFO:
                NSLog(@"下载监控通道数据。。。");
                break;
            case DOWNLOAD_ELECTRONIC_INFO:
                NSLog(@"下载家电信息数据。。。");
                break;
            case DOWNLOAD_SENSOR_INFO:
                NSLog(@"下载传感器信息数据。。。");
                break;
            case DOWNLOAD_SECURITY_INFO:
                NSLog(@"下载防区信息数据。。。");
                break;
            case DOWNLOAD_TIMER_INFO:
                NSLog(@"下载定时器信息。。。");
                break;
            case DOWNLOAD_ROOM_INFO:
                NSLog(@"下载房间信息。。。");
                break;
            case DOWNLOAD_FLOOR_INFO:
                NSLog(@"下载楼层信息。。。");
                break;
            case DOWNLOAD_USER_INFO:
                NSLog(@"下载客户端信息。。。");
                break;
            case DOWNLOAD_MONITOR_NETWORK_INFO:
                NSLog(@"下载监控网络参数。。。");
                break;
            case DOWNLOAD_PUSH_TAG:
                NSLog(@"下载推送tag");
                break;
            case DOWNLOAD_NEW_MONITOR_INFO:
                NSLog(@"下载新监控数据");
                break;
            case RECEIVE_SOCKET_ELECTRONIC_DATA:
                NSLog(@"接收设备电量状态");
                break;
            case RECEIVE_DEVICE_STATUS:
                NSLog(@"接收设备状态");
                break;
            case RECEIVE_TIMER_STATUS:
                NSLog(@"接收定时器状态");
                break;
            case RECEIVE_KT_STATUS:
                NSLog(@"接收空调状态");
                break;
            case RECEIVE_CONNECT_FAILD:
                NSLog(@"连接异常...");
                break;
            case RECEIVE_SECURITY_STATUS:
                break;
            case RECEIVE_READ_SECURITY_STATUS_ACK:
                NSLog(@"接收防区状态应答");
                break;
            case RECEIVE_ALARM_INFO:
                NSLog(@"接收报警信息");
                break;
            case RECEIVE_DISALARM_INFO:
                break;
            case RECEIVE_PASSWORD_CONFIRM:
                NSLog(@"接收密码确认");
                break;
            case RECEIVE_SECURITY_ARMING:
                break;
            case RECEIVE_READ_ALARM_MESSAGE:
                NSLog(@"读取报警信息");
                break;
            case RECEIVE_ADD_APPLIANCE:
                NSLog(@"添加家电");
                break;
            case RECEIVE_GET_APPLIANCE_LIST:
                NSLog(@"获取家电列表");
                break;
            case RECEIVE_LEARN_APPLIANCE_ORDER:
                break;
            case RECEIVE_DELETE_APPLIANCE_ORDER:
                break;
            case RECEIVE_DELETE_APPLIANCE:
                break;
            case RECEIVE_GET_APPLIANCE_LEARNED_ORDER:
                break;
            case RECEIVE_APPLIANCE_ORDER_CONTROL_STATUS:
                break;
            case RECEIVE_HEART_BEAT_DATA:
                //                NSLog(@"收到心跳包返回");
                [JY_NETWORK_INSTANCE stopGatewayHeartBeatCheckTimer];
                break;
                
            default:
                break;
        }
        if ([theDelegate respondsToSelector:@selector(jyReceiveGatewayData:)])
        {
            [theDelegate jyReceiveGatewayData:nsDic];
        }
        [gatewayReceiveArray removeObjectAtIndex:0];
    }
    
    if (gatewayReceiveArray.count > 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(gatewayDataAnalysis:) userInfo:nil repeats:NO];
    }
}

- (void)changeDownloadStatus
{
    NSLog(@"下载完成");
    //downloadStatus = STATUS_DOWNLOAD_FINISH;
    isRepeatData = NO;
    isDownloadMode = NO;
    [orderNumList removeAllObjects];
}

- (void)sendToServerWithTransitData:(NSString *)stringData
{
    unsigned int tempType = 0;
    unsigned int sendCmd = CLIENT_DATA_TRANSIT;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *transitDic = [[NSMutableDictionary alloc] init];
    [transitDic addEntriesFromDictionary:[stringData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    
    if ((sendCmd & 0x80) != 0x80)
    {
        sendCmd |= (++serverTcpOrderID << 8);
    }
    //增加中转数据中帧ID部分
    [[NSScanner scannerWithString:[transitDic objectForKey:@"type"]] scanHexInt:&tempType];
    if ((tempType & 0xFFFF)>>15 == 0)
    {
        tempType |= (++gatewayOrderID << 16);
    }
    [transitDic setObject:[NSString stringWithFormat:@"%x",tempType] forKey:@"type"];
    NSString *transitData = [transitDic JSONString];
    [orderDic setObject:[NSNumber numberWithInt:sendCmd] forKey:@"cmd"];
    [orderDic setObject:transitData forKey:@"data"];
    NSString *sendString = [orderDic JSONString];
    [sendString retain];
    [self sendToNetWithTcpData:sendString];
    [sendString release];
    [orderDic release];
    [transitDic release];
}

- (void)sendToGatewayWithTcpData:(NSString *)stringData
{
    unsigned int tempType = 0;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[stringData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    
    if((netConnectStatus == NET_CONNECTED || netConnectStatus == NET_CONNECTING))
    {
        [[NSScanner scannerWithString:[orderDic objectForKey:@"type"]] scanHexInt:&tempType];
        if ((tempType&0xFFFF)>>15 == 0)
        {
            tempType |= (++gatewayOrderID << 16);
        }
        [orderDic setObject:[NSString stringWithFormat:@"%x",tempType] forKey:@"type"];
        NSString *sendString = [orderDic JSONString];
        //            NSLog(@"(网关--TCP)发送:%@",sendString);
        [orderDic release];
        [self sendToNetWithTcpData:sendString];
    }
    else
    {
        //        tempType = tempType & 0xFF;
        //        NSLog(@"指令没有发送成功!");
        //        if (tempType == 0x20 || tempType == 0x24 || tempType == 0x25 || tempType == 0x26 || tempType == 0x31)
        //        {
        //            [self showAlertDialogWithTitle:NSLocalizedStringFromTable(@"Remind", @"InfoPlist",nil) withMsg:NSLocalizedStringFromTable(@"SendOrderFaild", @"InfoPlist",nil) withCancelBtnTitle:NSLocalizedStringFromTable(@"IGotIt", @"InfoPlist",nil) withOtherBtnTitle:nil withShowStyle:UIAlertViewStyleDefault withTag:0];
        //        }
    }
}

- (void)sendToServerWithTcpData:(NSString *)stringData
{
    unsigned int tempCmd = 0;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[stringData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    tempCmd = [(NSNumber *)[orderDic objectForKey:@"cmd"] intValue];
    
    if(serverConnectStatus == NET_CONNECTED)  //一定要在连接上服务器的时候才能发送数据
    {
        if ((tempCmd & 0x80) != 0x80)
        {
            tempCmd |= (++serverTcpOrderID << 8);
        }
        [orderDic setObject:[NSNumber numberWithInt:tempCmd] forKey:@"cmd"];
        NSString *sendString = [orderDic JSONString];
        [self sendToNetWithTcpData:sendString];
    }
    else
    {
        NSLog(@"(服务器--TCP):指令发送失败!");
        //        [self showAlertDialogWithTitle:NSLocalizedStringFromTable(@"Remind", @"InfoPlist",nil) withMsg:NSLocalizedStringFromTable(@"SendOrderFaild", @"InfoPlist",nil) withCancelBtnTitle:NSLocalizedStringFromTable(@"IGotIt", @"InfoPlist",nil) withOtherBtnTitle:nil withShowStyle:UIAlertViewStyleDefault withTag:0];
    }
}

- (void)sendToNetWithData:(NSString *)data withCommunicationType:(NSString *)communicationType
{
    if ([communicationType isEqualToString:@"UDP"])
    {
        [self sendToGatewayWithUdpData:data withHost:gatewayIPAddress withPort:gatewayPort];
    }
    else if([communicationType isEqualToString:@"TCP"])
    {
        if (communicationMode & MODE_DNS_ADDRESS)
        {
            [self sendToGatewayWithTcpData:data];
        }
        else
        {
            [self sendToServerWithTransitData:data];
        }
    }
}

- (void)sendToNetWithData:(NSString *)data withCommunicationMode:(int)commMode
{
    if (commMode & MODE_P2P_CONNECT)
    {
        [self sendToGatewayWithUdpData:data withHost:gatewayIPAddress withPort:gatewayPort];
    }
    if (commMode & MODE_TRANSIT_CONNECT)
    {
        [self sendToServerWithTransitData:data];
    }
    if (commMode & MODE_DNS_ADDRESS)
    {
        [self sendToNetWithTcpData:data];
    }
}

#pragma mark - 心跳包
- (void)startGatewayHeartBeatDataTimer
{
    [self stopGatewayHeartBeatDataTimer];
    if (gatewayHeartBeatTimer == nil)
    {
        gatewayHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:GATEWAY_HEARTBEART_PERIOD target:self selector:@selector(sendToGatewayWithHeartBeatData) userInfo:nil repeats:YES];
    }
}

- (void)stopGatewayHeartBeatDataTimer
{
    if (gatewayHeartBeatTimer != nil)
    {
        [gatewayHeartBeatTimer invalidate];
        gatewayHeartBeatTimer = nil;
    }
}

- (void)stopGatewayHeartBeatCheckTimer
{
    if (checkHeartBeatTimer != nil)
    {
        [checkHeartBeatTimer invalidate];
        checkHeartBeatTimer = nil;
    }
}

- (void)sendToGatewayWithHeartBeatData
{
    NSString *heartBeatData;
    NSMutableDictionary *heartBeatDic = [[NSMutableDictionary alloc] init];
    [heartBeatDic setObject:@"A0" forKey:@"type"];
    [heartBeatDic setObject:@"" forKey:@"name"];
    [heartBeatDic setObject:@"" forKey:@"CMD"];
    heartBeatData = [heartBeatDic JSONString];
    if (netConnectStatus == NET_CONNECTED)
    {
        [self sendToNetWithData:heartBeatData withCommunicationMode:communicationMode];
    }
    [heartBeatDic release];
    if (checkHeartBeatTimer == nil)
    {
        //NSLog(@"启动检查心跳包定时器");
        checkHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:CONNECT_TIMEOUT_PERIOD target:self selector:@selector(delayToCloseConnect) userInfo:nil repeats:NO];
    }
}

- (void)delayToCloseConnect
{
    NSLog(@"心跳包超时，自动断开连接");
    NSLog(@"%s %d", __FUNCTION__, __LINE__);
    [self clientCloseConnectToHost];
    if (gatewayHeartBeatTimer != nil)
    {
        [gatewayHeartBeatTimer invalidate];
        gatewayHeartBeatTimer = nil;
    }
    if (checkHeartBeatTimer != nil)
    {
        [checkHeartBeatTimer invalidate];
        checkHeartBeatTimer = nil;
    }
}

- (void)clientCloseConnectToHost
{
    if ((communicationMode & MODE_DNS_ADDRESS) || (communicationMode & MODE_TRANSIT_CONNECT))
    {
        [self closeTcpConnect];
    }
    else
    {
        NSLog(@"主动断开UDP连接！！！");
        netConnectStatus = NET_UNCONNECTED;
    }
}

- (void)startServerHeartBeatDataTimer
{
    [self stopServerHeartBeatDataTimer];
    if (self.serverHeartBeatTimer == nil)
    {
        self.serverHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:SERVER_HEARTBEART_PERIOD target:self selector:@selector(sendToServerWithHeartBeatData) userInfo:nil repeats:YES];
    }
}

- (void)stopServerHeartBeatDataTimer
{
    if (self.serverHeartBeatTimer != nil)
    {
        [self.serverHeartBeatTimer invalidate];
        self.serverHeartBeatTimer = nil;
    }
}

- (void)sendToServerWithHeartBeatData
{
    NSString *heartBeatData;
    NSMutableDictionary *heartBeatDic = [[NSMutableDictionary alloc] init];
    [heartBeatDic setObject:[NSNumber numberWithInt:SERVER_HEART_BEAT] forKey:@"cmd"];
    heartBeatData = [heartBeatDic JSONString];
    if (communicationMode & MODE_P2P_CONNECT)
    {
        [self sendToServerWithUdpData:heartBeatData];
    }
    [heartBeatDic release];
}

#pragma mark - 数据应答

- (void)sendAckData:(int)type withCommunicationType:(NSString *)communicationType
{
    if ((type & 0x8000) == 0x8000)
    {
        return;
    }
    int ackType = type | 0x8000;
    NSMutableDictionary *ackTypeDic = [NSMutableDictionary dictionary];
    [ackTypeDic setObject:[NSString stringWithFormat:@"%x",ackType] forKey:@"type"];
    [ackTypeDic setObject:@"" forKey:@"name"];
    [ackTypeDic setObject:@"" forKey:@"CMD"];
    NSString *ackData = [ackTypeDic JSONString];
    if ([communicationType isEqualToString:@"UDP"])
    {
        [self sendToGatewayWithUdpData:ackData withHost:gatewayIPAddress withPort:gatewayPort];
    }
    else if ([communicationType isEqualToString:@"TCP"])
    {
        [self sendToGatewayWithTcpData:ackData];
    }
}

- (void)sendServerAckData:(int)cmd withCommunicationType:(NSString *)communicationType
{
    int tempCmd = cmd & 0xFF;
    if ((tempCmd & 0x80) == 0x80)
    {
        return;
    }
    int ackCmd = cmd | 0x80;
    NSMutableDictionary *ackCmdDic = [[NSMutableDictionary alloc] init];
    [ackCmdDic setObject:[NSNumber numberWithInt:ackCmd] forKey:@"cmd"];
    [ackCmdDic setObject:[NSNumber numberWithInt:0] forKey:@"ret"];
    NSMutableString *ackData = [NSMutableString stringWithString:[ackCmdDic JSONString]];
    if ([communicationType isEqualToString:@"UDP"])
    {
        [self sendToServerWithUdpData:ackData];
    }
    else if ([communicationType isEqualToString:@"TCP"])
    {
        [self sendToServerWithTcpData:ackData];
    }
    [ackCmdDic setObject:[NSString stringWithFormat:@"%x",ackCmd] forKey:@"cmd"];
    ackData = [NSMutableString stringWithString:[ackCmdDic JSONString]];
    //    NSLog(@"(服务器)指令应答：%@", ackData);
    [ackCmdDic release];
}

- (void)sendTransitAckData:(NSString *)ackdata
{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    NSDictionary *ackDic = [ackdata objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    tempDic = [NSMutableDictionary dictionaryWithDictionary:ackDic];
    unsigned int typeInt = 0;
    [[NSScanner scannerWithString:[ackDic objectForKey:@"type"]] scanHexInt:&typeInt];
    if ((typeInt & 0x8000) == 0x8000)
    {
        return;
    }
    int ackType = typeInt | 0x8000;
    [tempDic setObject:[NSString stringWithFormat:@"%x",ackType] forKeyedSubscript:@"type"];
    [tempDic setObject:@"" forKeyedSubscript:@"name"];
    [tempDic setObject:@"" forKeyedSubscript:@"CMD"];
    NSMutableDictionary *ackTransitDic = [[NSMutableDictionary alloc] init];
    [ackTransitDic setObject:[NSNumber numberWithInt:CLIENT_DATA_TRANSIT] forKey:@"cmd"];
    [ackTransitDic setObject:[tempDic JSONString] forKey:@"data"];
    NSString *orderStr = [ackTransitDic JSONString];
    [self sendToServerWithTcpData:orderStr];
    [ackTransitDic release];
}

- (void)sendDownloadData:(int)mode
{
    NSMutableDictionary *downloadDic = [[NSMutableDictionary alloc] init];
    [downloadDic setObject:@"02" forKey:@"type"];
    [downloadDic setObject:@"" forKey:@"name"];
    [downloadDic setObject:@"FFFF" forKey:@"CMD"];
    NSString *downloadData = [downloadDic JSONString];
    if (mode == FUNCTION_LOCAL_CONNECTTION)
    {
        [self sendToNetWithData:downloadData withCommunicationMode:communicationMode];
    }
    else
    {
        if (communicationMode & MODE_TRANSIT_CONNECT)
        {
            [self sendToServerWithTransitData:downloadData];
        }
        else
        {
            [self sendToNetWithData:downloadData withCommunicationMode:communicationMode];
        }
    }
    [downloadDic release];
}

- (void)startDownload
{
    if (netConnectStatus == NET_CONNECTED)
    {
        if (isDownloadMode)
        {
            [self.changeDownloadStatusTimer invalidate];
            self.changeDownloadStatusTimer = nil;
            [self changeDownloadStatus];
        }
        [self sendDownloadData:functionMode];
        isDownloadMode = YES;
    }
}

#pragma mark - Util

- (NSString *)translateDataFormat:(NSString *)stringData  //与服务器的通信指令cmd字段转换为hex，方便分析
{
    unsigned int tempCmd = 0;
    NSString *cmdString = nil;
    NSMutableString *translateString = [NSMutableString stringWithString:stringData];
    NSRange range = [translateString rangeOfString:FRAME_END_STRING];
    if (range.length > 0)
    {
        [translateString deleteCharactersInRange:range];
    }
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[translateString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    tempCmd = [(NSNumber *)[orderDic objectForKey:@"cmd"] intValue];
    [orderDic setObject:[NSString stringWithFormat:@"%x",tempCmd] forKey:@"cmd"];
    cmdString = [NSString stringWithFormat:@"%x",tempCmd];
    [translateString appendString:FRAME_END_STRING];
    [translateString appendString:@"   "];
    [translateString appendString:cmdString];
    [orderDic release];
    return translateString;
}

- (NSMutableString *)addCommunicationTypeToData:(NSString *)stringData withCommunicationType:(NSString *)communicationType
{
    NSMutableString *receiveData = [NSMutableString stringWithString:stringData];
    if ([stringData hasSuffix:FRAME_END_STRING])
    {
        NSRange range = [receiveData rangeOfString:FRAME_END_STRING];
        if (range.length > 0)
            [receiveData deleteCharactersInRange:range];
    }
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic addEntriesFromDictionary:[receiveData objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode]];
    [orderDic setValue:communicationType forKey:@"socket"];
    receiveData = [NSMutableString stringWithString:[orderDic JSONString]];
    //    [receiveData appendString:FRAME_END_STRING];
    return receiveData;
}

#pragma mark - 数据重发机制

- (void)addOrderToServerSendListWithObject:(NSObject *)orderDic WithOrderID:(UInt8)orderID
{
    SendOrderModel *orderModel = [[SendOrderModel alloc] init];
    orderModel.orderObject = orderDic;
    orderModel.orderID = orderID;
    orderModel.sendTime = CURRENT_TIME;
    [self.serverOrderSendList addObject:orderModel];
    [orderModel release];
}

- (void)addOrderToGatewaySendListWithObject:(NSObject *)orderDic WithOrderID:(UInt8)orderID
{
    SendOrderModel *orderModel = [[SendOrderModel alloc] init];
    orderModel.orderObject = orderDic;
    orderModel.orderID = orderID;
    orderModel.sendTime = CURRENT_TIME;
    [self.gatewayOrderSendList addObject:orderModel];
    [orderModel release];
}

- (void)updataServerSendListWithOrderID:(UInt8)orderID
{
    for (int i = 0; i < self.serverOrderSendList.count; i++)
    {
        UInt8 tempOrderID = ((SendOrderModel *)[serverOrderSendList objectAtIndex:i]).orderID;
        if (orderID == tempOrderID)
        {
            [self.serverOrderSendList removeObjectAtIndex:i];
        }
    }
}

- (void)updataGatewaySendListWithOrderID:(UInt8)orderID
{
    for (int i = 0; i < self.gatewayOrderSendList.count; i++)
    {
        UInt8 tempOrderID = ((SendOrderModel *)[gatewayOrderSendList objectAtIndex:i]).orderID;
        if (orderID == tempOrderID)
        {
            [self.gatewayOrderSendList removeObjectAtIndex:i];
        }
    }
}

- (void)updataResendListWithOrderString:(NSString *)receiveString
{
    NSMutableString *jsonString = [NSMutableString stringWithString:receiveString];
    NSRange range = [jsonString rangeOfString:FRAME_END_STRING];
    if (range.length > 0)
        [jsonString deleteCharactersInRange:range];
    NSDictionary *receiveDic = [jsonString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    UInt16 orderNum = 0;
    
    if ([[receiveDic allKeys] containsObject:@"type"])
    {
        unsigned int typeInt = 0;
        [[NSScanner scannerWithString:[receiveDic objectForKey:@"type"]] scanHexInt:&typeInt];
        orderNum = typeInt >> 16;
        [self updataGatewaySendListWithOrderID:orderNum];
    }
    else if ([[receiveDic allKeys] containsObject:@"cmd"])
    {
        UInt16 cmd = [[receiveDic objectForKey:@"cmd"] integerValue];
        orderNum = cmd >> 8;
        if ([[receiveDic allKeys] containsObject:@"ran"])
        {
            [self updataGatewaySendListWithOrderID:orderNum];
        }
        else
        {
            [self updataServerSendListWithOrderID:orderNum];
        }
    }
}

- (void)clearResendBuffer
{
    [self.serverOrderSendList removeAllObjects];
    [self.gatewayOrderSendList removeAllObjects];
}

- (void)startResendThread
{
    [NSThread detachNewThreadSelector:@selector(resendGatewayDataThread:) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(resendServerDataThread:) toTarget:self withObject:nil];
}

- (void)resendServerDataThread:(id)anObj
{
    @synchronized(anObj)
    {
        while (YES)
        {
            [NSThread sleepForTimeInterval:1.0];
            for (int i = 0; i < serverOrderSendList.count; i++)
            {
                UInt64 currentTime = CURRENT_TIME;
                UInt64 orderSendTime = ((SendOrderModel *)[serverOrderSendList objectAtIndex:i]).sendTime;
                UInt8 orderResendTimes = ((SendOrderModel *)[serverOrderSendList objectAtIndex:i]).resendTimes;
                //                NSLog(@"当前时间：%llu",currentTime);
                //                NSLog(@"指令时间：%llu",orderSendTime);
                //                NSLog(@"时间差：%llu",(currentTime - orderSendTime));
                if ((currentTime - orderSendTime) >= RESEND_TIME && orderResendTimes < 4)
                {
                    //                    NSLog(@"%llu",(currentTime - orderSendTime));
                    NSString *resendData = ((NSString *)((SendOrderModel *)[serverOrderSendList objectAtIndex:i]).orderObject);
                    if (orderResendTimes == 3)
                    {
                        NSLog(@"(服务器)重发次数已超过3次，抛弃");
                        [serverOrderSendList removeObjectAtIndex:i];
                    }
                    else
                    {
                        //其实这个也是在子线程中执行的，只是把它放到了主线程的队列中
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if ([resendData containsString:@"ran"])
                            {
                                [self sendToNetWithUdpData:resendData withHost:gatewayIPAddress withPort:gatewayPort];
                            }
                            else
                            {
                                [self sendToNetWithUdpData:resendData withHost:SERVER_IP withPort:SERVER_PORT];
                            }
                            
                        });
                        if (serverOrderSendList.count > 0)
                        {
                            //此处出现过闪退
                            ((SendOrderModel *)[serverOrderSendList objectAtIndex:i]).resendTimes += 1;
                        }
                    }
                }
            }
        }
    }
}

- (void)resendGatewayDataThread:(id)anObj
{
    @synchronized(anObj)
    {
        while (YES)
        {
            [NSThread sleepForTimeInterval:1.0];
            for (int i = 0; i < gatewayOrderSendList.count; i++)
            {
                UInt64 currentTime = CURRENT_TIME;
                UInt64 orderSendTime = ((SendOrderModel *)[gatewayOrderSendList objectAtIndex:i]).sendTime;
                UInt8 orderResendTimes = ((SendOrderModel *)[gatewayOrderSendList objectAtIndex:i]).resendTimes;
                //                NSLog(@"当前时间：%llu",currentTime);
                //                NSLog(@"指令时间：%llu",orderSendTime);
                //                NSLog(@"时间差：%llu",(currentTime - orderSendTime));
                if ((currentTime - orderSendTime) >= RESEND_TIME && orderResendTimes < 4)
                {
                    //                    NSLog(@"%llu",(currentTime - orderSendTime));
                    NSString *resendData = ((NSString *)((SendOrderModel *)[gatewayOrderSendList objectAtIndex:i]).orderObject);
                    if (orderResendTimes == 3)
                    {
                        NSLog(@"(网关)重发次数已超过3次，抛弃");
                        [gatewayOrderSendList removeObjectAtIndex:i];
                    }
                    else
                    {
                        //其实这个也是在子线程中执行的，只是把它放到了主线程的队列中
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self sendToNetWithUdpData:resendData withHost:gatewayIPAddress withPort:gatewayPort];
                        });
                        if (gatewayOrderSendList.count > 0)
                        {
                            ((SendOrderModel *)[gatewayOrderSendList objectAtIndex:i]).resendTimes += 1;
                        }
                    }
                }
            }
        }
    }
}






@end
