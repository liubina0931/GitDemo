#import "TCPClient.h"

@implementation TCPClient : TCP

- (TCPClient *) initWithDelegate: (id) delegate
{
	self = [super init];	
	[self setTheDelegate: delegate];
	NSLog (@"Creating socket.");
	socket = [[AsyncSocket alloc] initWithDelegate:self];
	return self;
}

/*	Attempts connection, returns YES when host located and no errors detected but before connection made.
	-didConnectToHost called when connection made.
 */
-(BOOL) connectHost: (NSString *) host port: (UInt16) port
{
	@try
	{
		NSError *err;
		
		BOOL res = [socket connectToHost:host onPort:port error:&err];
		if (res) {
			NSLog (@"Connecting to %@ port %u.", host, port);
			return YES;
		}
		else {
			NSLog (@"Could not connect. Error domain %@, code %ld (%@).",
				   [err domain], (long)[err code], [err localizedDescription]);
		}
	}
	@catch (NSException *exception)
	{
		NSLog (@"%@", [exception reason]);
	}	
	return NO;
}

-(void) disconnect
{
	[socket disconnect];
}


#pragma mark AsyncSocket Delegate Methods

/*
 This method is called when connection to server. Immediately
 wait for incoming data from the server.
*/
-(void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	NSLog (@"Connected to %@ %u.", host, port);
	if ([theDelegate respondsToSelector:@selector(didConnectToHost)])
		[theDelegate didConnectToHost];	
	
	[socket readDataWithTimeout:-1 tag:0];
}
@end
