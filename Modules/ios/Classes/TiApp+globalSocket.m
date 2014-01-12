//
//  TiApp+globalSocket.m
//  rapid
//
//  Created by Matt Apperson on 1/6/14.
//
//

#import "TiApp+globalSocket.h"
#import "TiExceptionHandler.h"


static SRWebSocket * WS = nil;
static BOOL connected = nil;

@implementation TiApp (globalSocket)

#pragma mark Cleanup

-(void)dealloc
{
    if ([TiApp.WS retainCount] == 1) {
        // as SRWebScoket library uses ARC, let's be careful releasing the object
        // so, if retain counter = 1, we are sure nobody else retains it
        RELEASE_TO_NIL(WS);
    }
	// release any resources that have been retained by the module
	[super dealloc];
}

+ (SRWebSocket *) WS
{
    return WS;
}
+ (BOOL) connected
{
    return connected;
}

+ (SRWebSocket *) WS: (SRWebSocket *) socket
{
    if(!WS) WS = socket;
}
+ (BOOL) connected: (BOOL) state
{
    connected = state;
}

@end
