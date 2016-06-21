#import "TCP.h"

#pragma mark -
#pragma mark 编码转换

//在工程的Framework部分加入 libiconv.dylib
/*
#include <iconv.h>

int code_convert(char *from_charset, char *to_charset, char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
    iconv_t cd = NULL;
	
    cd = iconv_open(to_charset, from_charset);
    if(!cd)
        return -1;
	
    memset(outbuf, 0, outlen);
    if(iconv(cd, &inbuf, &inlen, &outbuf, &outlen) == -1)
        return -1;
	
    iconv_close(cd);
    return 0;
}

int u2g(char *inbuf, size_t inlen, char *outbuf, size_t outlen) {
    return code_convert("utf-8", "gb2312", inbuf, inlen, outbuf, outlen);
}

int g2u(char *inbuf, size_t inlen, char *outbuf,size_t outlen) {
    return code_convert("gb2312", "utf-8", inbuf, inlen, outbuf, outlen);
}
*/
#pragma mark -

@implementation TCP : NSObject
@synthesize theDelegate;

/*
 Sends data to host connected to socket.
 */
-(void) sendData: (NSString *) nsData {
//    NSLog(@"TCP 发送:%@",nsData);
	NSData *data = [nsData  dataUsingEncoding:NSASCIIStringEncoding];//转换数据类型
	[socket writeData: data withTimeout:-1 tag:0];//发送数据
}

/*
 Called on disconnect. Calls delegate method -didDisconnectFromHost and releases the 
 socket used for communicating with host.
 */
-(void) onSocketDidDisconnect: (AsyncSocket *)sock {
	NSLog (@"TCP onSocketDidDisconnect.");
	if ([theDelegate respondsToSelector:@selector(didDisconnectFromHost)])//设置代理
		[theDelegate didDisconnectFromHost];//调用代理 
}

/*
 Called whenever AsyncSocket is about to disconnect due to an error. 
 Does not do anything other than report what went wrong (this delegate method
 is the only place to get that information), but in a more serious app, this is
 a good place to do disaster-recovery by getting partially-read data. This is
 not, however, a good place to do cleanup. The socket must still exist when this
 method returns.
 */
-(void) onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	if (err != nil)
		NSLog (@"Socket will disconnect. Error domain %@, code %ld (%@).",
			   [err domain], (long)[err code], [err localizedDescription]);
	else
		NSLog (@"Socket will disconnect. No error.");
}

- (NSString *)getANSIString:(NSData *)ansiData {
    int ansiLen = (int)[ansiData length];
	char *ansiString = (char *)malloc(ansiLen);
	memcpy(ansiString, [ansiData bytes], ansiLen);
    int utf8Len = ansiLen * 2; //其实*1.5基本就够了
    char *utf8String = (char *)malloc(utf8Len);
    memset(utf8String, 0, utf8Len); //虽然code_convert中也memset了, 但还是自己分配后就set一次比较好

   // int result = code_convert("gb2312", "utf-8", ansiString, ansiLen, utf8String, utf8Len);
   // result = result;
   /* if(result == -1) {
        free(utf8String);
        return nil;
    }
    NSString *retString = [NSString stringWithUTF8String:ansiString];
    free(ansiString);*/
    
    NSString *retString = [NSString stringWithUTF8String:utf8String];
    free(utf8String);
    return retString;
}

/*
 Called when has finished reading a data packet.
 Prints data, pasess to delegate -receiveData method, then
 calls -readDataToData, which will queue up a
 read operation, waiting for the next packet.
 */

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{
    /*NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length])];
	NSString *msg = [self getANSIString: strData];
    NSLog(@"TCP接收到：%@", msg);*/
    if ([theDelegate respondsToSelector:@selector(receiveData:)])
		[theDelegate receiveData:data];
    
	//[sock readDataWithTimeout:-1 tag:0];
    NSData *endString = [@"&]" dataUsingEncoding:NSASCIIStringEncoding];
    [sock readDataToData:endString withTimeout:-1 tag:0];
}	

/*
 Release allocated resources, including the socket. The socket will close
 any connection before releasing itself.
 */
- (void)dealloc
{
	[socket release];
	[super dealloc];
}
@end