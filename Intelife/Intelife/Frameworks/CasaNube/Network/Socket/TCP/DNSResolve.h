//
//  DNSResolve.h
//  SmartHome
//
//  Created by Gao Yusong on 11-8-4.
//  Copyright 2011年 zxfe.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>
#include <netinet/in.h>     // INET6_ADDRSTRLEN
#include <netdb.h>          // getaddrinfo, struct addrinfo, AI_NUMERICHOST


@interface DNSResolve : NSObject {
    id          theDelegate;
    NSString    *hostName;
}

@property (nonatomic, retain) NSString *hostName;

- (DNSResolve *) initWithDelegate: (id) delegate;
- (void)resolve:(NSString *)hostName;

@end

@interface DNSResolve (DNSResolvePrivate)

- (void)resolved:(NSMutableArray *)array;

@end

@interface DNSResolve (DNSResolveDelegate)

- (void)ztOnResolved:(NSArray *)ipArray;

@end