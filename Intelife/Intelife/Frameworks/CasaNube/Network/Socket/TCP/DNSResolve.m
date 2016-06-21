//
//  DNSResolve.m
//  SmartHome
//
//  Created by Gao Yusong on 11-8-4.
//  Copyright 2011年 zxfe.cn. All rights reserved.
//

#import "DNSResolve.h"

@implementation DNSResolve

@synthesize hostName;


static void
MyResolveEnd(void *selfobj, void* ipArray) 
{
    DNSResolve *dns = (DNSResolve *)selfobj;
    [dns resolved:((NSMutableArray *)ipArray)];
}

static void
MyPrintAddressArray(CFArrayRef addresses, void *info)
{
    struct sockaddr  *addr;
    char             ipAddress[INET6_ADDRSTRLEN];
    CFIndex          index, count;
    char             *name;
    CFIndex          nameLength;
    Boolean          success;
    int              err;
    CFStringRef      hostName;
    
    DNSResolve *dns = (DNSResolve *)info;
    NSString *nsHost = dns.hostName;
    const char *cHost = [nsHost cStringUsingEncoding:NSASCIIStringEncoding];
    hostName = CFStringCreateWithCString(NULL, cHost, kCFStringEncodingASCII);
    
    assert(addresses != NULL);
    assert(hostName != NULL);
    
    /* CFStringGetMaximumSizeForEncoding determines max bytes a string of specified length will take up if encoded. */
    nameLength = CFStringGetMaximumSizeForEncoding(CFStringGetLength(hostName), kCFStringEncodingASCII);
    name = malloc(nameLength + 1);
    assert(name != NULL);
    
    success = CFStringGetCString(hostName, name, nameLength + 1, kCFStringEncodingASCII);
    assert(success);
    
    count = CFArrayGetCount(addresses);
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:count];
    for (index = 0; index < count; index++) {
        addr = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addresses, index));
        assert(addr != NULL);
        
        /* getnameinfo coverts an IPv4 or IPv6 address into a text string. */
        err = getnameinfo(addr, addr->sa_len, ipAddress, INET6_ADDRSTRLEN, NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            printf("%s -> %s\n", name, ipAddress);
            NSString *nsIp = [NSString stringWithCString:ipAddress encoding:NSASCIIStringEncoding];
            [array addObject:nsIp];
        } else {
            printf("getnameinfo returned %d\n", err);
        }
    }
    free(name);   
    CFRelease(hostName);
    
    [dns resolved:[array autorelease]];
}

static void
MyCFHostCleanup(CFHostRef host)
{
    assert(host != NULL);
    
    /* CFHostUnscheduleFromRunLoop unschedules the given host from a run loop and mode
     so the client will not receive its callbacks on that loop and mode. */
    CFHostUnscheduleFromRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    /* This removes the client callback association from the host object. */
    (void) CFHostSetClient(host, NULL, NULL);
    
    CFRelease(host);
}



static void
MyCFHostClientCallBack(CFHostRef host, CFHostInfoType typeInfo, const CFStreamError *error, void *info)
{  
    CFArrayRef   array;
    
    if (error->error == noErr) {
        
        switch (typeInfo) {
                
            case kCFHostAddresses:
                /* CFHostGetAddressing retrieves the known addresses from the given host. Returns a
                 CFArrayRef of addresses.  Each address is a CFDataRef wrapping a struct sockaddr. */
                array = CFHostGetAddressing(host, NULL);
                MyPrintAddressArray(array, info);
                break;
            default:
                fprintf(stderr, "Unknown CFHostInfoType (%d)\n", typeInfo);
                break;
        }
    } else {
        fprintf(stderr, "MyCFHostClientCallBack returned (%ld, %d)\n", error->domain, (int)error->error);
        MyResolveEnd(info, nil);
    }
    
    ///* The CFHost callback only gets called once, so we cleanup now that we're done. */
    //MyCFHostCleanup(host);
    
    /* Stop the run loop now that we've retrieved the host info. */
    CFRunLoopStop(CFRunLoopGetCurrent());
}



static Boolean
MyResolveNameToAddress(CFStringRef hostName, void *selfObj)
{
    CFHostRef            host;
    CFHostClientContext  context = { 0, selfObj, CFRetain, CFRelease, NULL };
    CFStreamError        error;
    Boolean              success;
    
    assert(hostName != NULL);
    
    /* Creates a new host object with the given name. */
    host = CFHostCreateWithName(kCFAllocatorDefault, hostName);
    assert(host != NULL);
    
    /* CFHostSetClient associates a client context and callback function with a CFHostRef.
     This is required for asynchronous usage.  If not set, resolve will take place synchronously. */
    success = CFHostSetClient(host, MyCFHostClientCallBack, &context);
    if (success) {
        
        /* CFHostScheduleWithRunLoop schedules the given host on a run loop and mode so
         the client will receive its callbacks on that loop and mode. */
        CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        
        /* CFHostStartInfoResolution performs a lookup for the given host.
         It will search for the requested information if there is no other active request. */
        success = CFHostStartInfoResolution(host, kCFHostAddresses, &error);
        if (!success) {
            fprintf(stderr, "CFHostStartInfoResolution returned (%ld, %d)\n", error.domain, (int)error.error);
            MyCFHostCleanup(host);
        }
    } else {
        fprintf(stderr, "CFHostSetClient failed\n");
        MyResolveEnd(selfObj, nil);
    }  
    if(host != NULL)
        CFRelease(host);
    
    return success;
}


#pragma mark -

- (DNSResolve *) initWithDelegate: (id) delegate {
    if ((self = [super init])) {
        theDelegate = delegate;
    }
    return self;
}

- (void)resolve:(NSString *)host {
    
    self.hostName = host;
    
    CFStringRef  inputString;
    Boolean      success;
    
    const char* cHost = [host cStringUsingEncoding:NSASCIIStringEncoding];
    inputString = CFStringCreateWithCString(NULL, cHost, kCFStringEncodingASCII);
    assert(inputString != NULL);
    
    /* MyResolveNameToAddress retrieves the IP addresses for a hostname. */
    success = MyResolveNameToAddress(inputString, self);
    if (!success) fprintf(stderr, "MyResolveNameToAddress failed\n");
    
    
    CFRelease(inputString);
    
    /* Start the run loop to receive asynchronous callbacks via MyCFHostClientCallBack. */
    if (success) CFRunLoopRun();
}

- (void)resolved:(NSMutableArray*)array {
    if ([theDelegate respondsToSelector:@selector(ztOnResolved:)]) {        
        [theDelegate ztOnResolved:array];
    }
}


@end
