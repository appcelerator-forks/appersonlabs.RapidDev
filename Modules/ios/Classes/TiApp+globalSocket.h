//
//  TiApp+globalSocket.h
//  rapid
//
//  Created by Matt Apperson on 1/6/14.
//
//

#import "TiApp.h"
#import "SRWebSocket.h"
#import "JRSwizzle.h"
#import "ComAppersonlabsRapiddevModule.h"


@interface TiApp (globalSocket)
+ (SRWebSocket *) WS;
+ (BOOL) connected;

+ (void) WS: (SRWebSocket *) socket;
+ (void) connected: (BOOL) state;

@end
