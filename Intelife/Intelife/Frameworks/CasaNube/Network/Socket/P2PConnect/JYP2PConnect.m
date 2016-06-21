//
//  JYP2PConnect.m
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-6-15.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import "JYP2PConnect.h"
#import "GlobalDefines.h"
#import "JSONKit.h"
#import "SecKeyWrapper.h"
#import "CryptoCommon.h"
#import "GlobalVariable.h"
#import "JYNetworkAnalyse.h"
#import "Database.h"

@implementation JYP2PConnect


SYNTHESIZE_SINGLETON_FOR_CLASS(JYP2PConnect);

- (id)init
{
    if((self = [super init]))
    {
        
    }
    
    return self;
}

#pragma mark -P2P 连接处理

- (void)getUdpTempLoginKey
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_GET_TEMP_KEY] forKey:@"cmd"];
    NSString *sendData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:sendData];
    [orderDic release];
}

- (void)getTcpTempLoginKey
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_GET_TEMP_KEY] forKey:@"cmd"];
    NSString *sendData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithTcpData:sendData];
    [orderDic release];
}

- (void)clientLoginAccount
{
    tempKeyType = TYPE_TEMP_KEY_LOGIN;
    loginAccountType = TYPE_LOGIN_ACTIVE;
#if USE_P2P_CONNECT
    communicationMode = MODE_P2P_CONNECT | MODE_TRANSIT_CONNECT;
    [self getUdpTempLoginKey];  //获取UDP临时密钥
#else
    communicationMode = MODE_TRANSIT_CONNECT;
#endif
    [JY_NETWORK_INSTANCE creatTcpConnect:SERVER_IP port:SERVER_PORT];  //与服务器建立TCP连接
}

- (void)clientLogoutAccount
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_LOGOUT_ACCOUNT] forKey:@"cmd"];
    NSString *sendData = [orderDic JSONString];
    if (communicationMode & MODE_P2P_CONNECT)
    {
        //        self.p2pLoginStatus = LOGIN_FAILED;
        [JY_NETWORK_INSTANCE sendToServerWithUdpData:sendData];
    }
    if (communicationMode & MODE_TRANSIT_CONNECT)
    {
        //        self.transitLoginStatus = LOGIN_FAILED;
        [JY_NETWORK_INSTANCE sendToServerWithTcpData:sendData];
    }
    if (communicationMode & MODE_DNS_ADDRESS)
    {
        [JY_NETWORK_INSTANCE sendToServerWithUdpData:sendData];
    }
    [orderDic release];
}

- (void)findGatewayIP
{
    if (phoneNetworkStatus == STATUS_WIFI_NETWORK)
    {
        NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
        [orderDic setObject:[NSNumber numberWithInt:BROUNDCAST_FIND_GATEWAY_IP] forKey:@"cmd"];
        NSString *udpDataStr = [orderDic JSONString];
        [JY_NETWORK_INSTANCE sendToGatewayWithUdpBroadcast:udpDataStr];
        [orderDic release];
    }
    else
    {
        NSLog(@"当前网络为非WIFI环境，不发送广播数据！！！");
    }
}

- (void)findOnlineGateway
{
    if (phoneNetworkStatus != STATUS_WWAN_NETWORK)
    {
        NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
        [orderDic setObject:[NSNumber numberWithInt:BROUNDCAST_FIND_DEVICE] forKey:@"cmd"];
        NSString *udpDataStr = [orderDic JSONString];
        [JY_NETWORK_INSTANCE sendToGatewayWithUdpBroadcast:udpDataStr];
        [orderDic release];
    }
    else
    {
        NSLog(@"当前网络为非WIFI环境，不发送广播数据！！！");
    }
}

- (void)requestConnectWithCommunicationType:(NSString *)communicationType
{
//    gatewayIPAddress = @"192.168.66.22";
//    gatewayPort = 16899;
    if (gUUID == nil || [gUUID isEqualToString:@""])
    {
        gUUID = @"l123456789";
    }
    NSMutableDictionary *connectDic = [NSMutableDictionary dictionary];
    [connectDic setObject:@"01" forKey:@"type"];
    [connectDic setObject:gUUID forKey:@"name"];
    [connectDic setObject:@"01" forKey:@"CMD"];
    NSString *connectData = [connectDic JSONString];
    netConnectStatus = NET_CONNECTING;
    [JY_NETWORK_INSTANCE sendToNetWithData:connectData withCommunicationType:communicationType];
}

- (NSMutableString *)getEncryptedData:(NSString *)data
{
    NSString *plainText = data;//明文
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    //生成密钥
    NSData *symmetricKeyData = [commonKey dataUsingEncoding:NSUTF8StringEncoding];
    CCOptions pad = kCCOptionPKCS7Padding;
    
    //进行加密
    NSData *encryptedData = [[SecKeyWrapper sharedWrapper] doCipher:textData key:symmetricKeyData context:kCCEncrypt padding:&pad];//默认加密模式为AES/CBC/PKCS7
    
    Byte *plainTextByte =(Byte *)[encryptedData bytes];
    NSMutableString *encryptedPassword = [[[NSMutableString alloc] init] autorelease];
//    NSLog(@"Plain text = %@",plainText);
//    NSLog(@"Encrpted data = ");
    //加密后的数据
    for (int i = 0; i < [encryptedData length]; i ++)
    {
        //        printf("%x",plainTextByte[i]);
        if (plainTextByte[i] <= 0x0F)
        {
            [encryptedPassword appendString:@"0"];
        }
        [encryptedPassword appendString:[NSString stringWithFormat:@"%x",plainTextByte[i]]];
    }
    return encryptedPassword;
}


- (void)startLoginWithUserName:(NSString *)username withPassword:(NSString *)password withCommunicationtype:(UInt8)communicationType
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_LOGIN_ACCOUNT] forKey:@"cmd"];
    [orderDic setObject:username forKey:@"uid"];
    [orderDic setObject:[NSNumber numberWithInt:1] forKey:@"ver"];
    [orderDic setObject:[self getEncryptedData:password] forKey:@"pw"];
    NSMutableString *sendLoginData = [[NSMutableString alloc] init];
    sendLoginData = [NSMutableString stringWithString:[orderDic JSONString]];
    if (communicationType == TYPE_SOCKET_UDP)
    {
        [JY_NETWORK_INSTANCE sendToServerWithUdpData:sendLoginData];
    }
    else if (communicationType == TYPE_SOCKET_TCP)
    {
        [JY_NETWORK_INSTANCE sendToServerWithTcpData:sendLoginData];
    }
    [orderDic release];
}

- (void)registAccountwithUserName:(NSString *)userName withPassword:(NSString *)password withEmail:(NSString *)email
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_REGISTER_ACCOUNT] forKey:@"cmd"];
    [orderDic setObject:userName forKey:@"uid"];
    [orderDic setObject:email forKey:@"email"];
    [orderDic setObject:[self getEncryptedData:password] forKey:@"pw"];
    NSString *sendRegistData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:sendRegistData];
    [orderDic release];
}

- (void)editPasswordWithOldPassword:(NSString *)oldPassword withSetPassword:(NSString *)setPassword
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:EDIT_ACCOUNT_PASSWORD] forKey:@"cmd"];
    [orderDic setObject:[self getEncryptedData:oldPassword] forKey:@"opw"];
    [orderDic setObject:[self getEncryptedData:setPassword] forKey:@"pw"];
    NSString *editPasswordData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:editPasswordData];
    [orderDic release];
}

- (void)findPasswordWithUserName:(NSString *)userName
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:FIND_ACCOUNT_PASSWORD] forKey:@"cmd"];
    [orderDic setObject:userName forKey:@"uid"];
    NSString *findPasswordData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:findPasswordData];
    [orderDic release];
}

- (void)loginToServerWithCommunicationType:(NSString *)type
{
    if (tempKeyType == TYPE_TEMP_KEY_LOGIN && loginUsername != nil && loginPassword != nil)
    {
        if (loginUsername.length == 0 || loginPassword.length == 0)
            return;
        if ([type isEqualToString:@"TCP"])
        {
            [self startLoginWithUserName:loginUsername withPassword:loginPassword withCommunicationtype:TYPE_SOCKET_TCP];
        }
        else if ([type isEqualToString:@"UDP"])
        {
            [self startLoginWithUserName:loginUsername withPassword:loginPassword withCommunicationtype:TYPE_SOCKET_UDP];
        }
    }
}

- (void)p2pReloginToServer
{
    if (communicationMode != MODE_DNS_ADDRESS /*&& p2pLoginStatus == LOGIN_SUCCESS*/ && phoneNetworkStatus != STATUS_NOT_REACHABLE)
    {
        tempKeyType = TYPE_TEMP_KEY_LOGIN;
        loginAccountType = TYPE_LOGIN_AUTO;
//        transitLoginStatus = LOGIN_FAILED;   //去掉这里将登陆状态设置为失败，防止在平板上运行时没网导致下次不会重连
//        p2pLoginStatus = LOGIN_FAILED;
        netConnectStatus = NET_CONNECTING;
#if USE_P2P_CONNECT
        communicationMode = MODE_P2P_CONNECT | MODE_TRANSIT_CONNECT;
        [self getUdpTempLoginKey];  //获取UDP临时密钥
#else
        communicationMode = MODE_TRANSIT_CONNECT;
#endif
        [JY_NETWORK_INSTANCE creatTcpConnect:SERVER_IP port:SERVER_PORT];
    }
}

- (void)clientTryP2PConnectWithIP:(NSString *)host withPort:(UInt16)port
{
//    host = @"192.168.66.163";
//    port = 16899;
    if (host == nil || port == 0)
        return;
    netConnectStatus = NET_CONNECTING;
//    loginAccountType = TYPE_LOGIN_ACTIVE;
    communicationMode |= MODE_P2P_CONNECT;
    gatewayIPAddress = host;
    gatewayPort = port;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    int randValue = arc4random() % 1000;
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_TRY_P2P_CONNECT] forKey:@"cmd"];
    [orderDic setObject:[NSNumber numberWithInt:randValue] forKey:@"ran"];
    NSString *orderStr = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToGatewayWithUdpData:orderStr withHost:host withPort:port];
    [orderDic release];
}

- (void)clientStartP2PConnectWithMac:(long long)mac
{
    if (mac > 0)
    {
        NSLog(@"客户端发起P2P连接。。。");
        communicationMode |= MODE_P2P_CONNECT;  //加上这个防止第一次P2P成功连接之后再次连接出现的重复连接多次问题
        netConnectStatus = NET_CONNECTING;
//        [self clientDataTransit:mac];  //进行P2P连接的时候先进行中转连接
        NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
        [orderDic setObject:[NSNumber numberWithInt:CLIENT_START_P2P_CONNECT] forKey:@"cmd"];
        [orderDic setObject:[NSNumber numberWithLongLong:mac] forKey:@"mac"];
        NSString *p2pConnectData = [orderDic JSONString];
        [JY_NETWORK_INSTANCE sendToServerWithUdpData:p2pConnectData];
        [orderDic release];
        //保存当前连接网关信息
        NSMutableDictionary *gatewayDic = [[NSMutableDictionary alloc] init];
        [gatewayDic setObject:[NSString stringWithFormat:@"%lld", mac] forKey:@"gatewayMac"];
        [JY_DATABASE_INSTANCE updataItemToTable:@"RemoteGatewayInfo" withValues:gatewayDic withWhere:@"_id=?" withArgs:@"1"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadControlDeviceListMsg" object:nil];
    }
}

- (void)noticeP2PConnectSuccess
{
    NSLog(@"P2P连接成功");
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:NOTICE_P2P_CONNECT_SUCCESS] forKey:@"cmd"];
    NSString *p2pSuccessData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:p2pSuccessData];
    [orderDic release];
}

- (void)noticeP2PConnectFailed
{
    NSLog(@"P2P连接失败，进行中转连接");
    communicationMode = MODE_TRANSIT_CONNECT;   //此处需要考虑是否添加通信模式保存数据库部分
}

- (void)clientCloseTransitConnect
{
//    NSLog(@"%s %d", __FUNCTION__, __LINE__);
//    if (communicationMode != MODE_DNS_ADDRESS)
//    {
//        NSLog(@"P2P连接成功，断开中转连接");
//        [JY_NETWORK_INSTANCE closeTcpConnect];
//    }
}

- (void)clientDataTransit:(long long)mac
{
    if (mac <= 0)
        return;
//    communicationMode |= MODE_TRANSIT_CONNECT;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_TRANSIT_CONNECT] forKey:@"cmd"];
    [orderDic setObject:[NSNumber numberWithLongLong:mac] forKey:@"mac"];
    NSString *tryTransitData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithTcpData:tryTransitData];
    [orderDic release];
}

- (void)clientAddDeviceWithMac:(long long)mac
{
    if (mac <= 0)
        return;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_ADD_DEVICE] forKey:@"cmd"];
    [orderDic setObject:[NSNumber numberWithLongLong:mac] forKey:@"mac"];
    NSString *addDeviceData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:addDeviceData];
    [orderDic release];
}

- (void)clientDeleteDeviceWithMac:(long long)mac
{
    if (mac <= 0)
        return;
    currentDeleteGatewayMac = mac;
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_DELETE_DEVICE] forKey:@"cmd"];
    [orderDic setObject:[NSNumber numberWithLongLong:mac] forKey:@"mac"];
    NSString *deleteDeviceData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:deleteDeviceData];
    [orderDic release];
}

- (void)getGatewayP2PMac:(NSString *)gatewaySymbol
{
    NSMutableDictionary *orderDic = [[NSMutableDictionary alloc] init];
    [orderDic setObject:[NSNumber numberWithInt:CLIENT_GET_GATEWAY_MAC] forKey:@"cmd"];
    [orderDic setObject:[NSNumber numberWithInt:TYPE_CAMERA_GATEWAY] forKey:@"type"];
    [orderDic setObject:gatewaySymbol forKey:@"name"];
    NSString *getGatewayMacData = [orderDic JSONString];
    [JY_NETWORK_INSTANCE sendToServerWithUdpData:getGatewayMacData];
    [orderDic release];
}




@end
