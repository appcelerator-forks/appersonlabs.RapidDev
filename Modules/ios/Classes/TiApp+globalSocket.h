//
//  TiApp+globalSocket.h
//  rapid
//
//  Created by Matt Apperson on 1/6/14.
//
//

#import "TiApp.h"
#import "SRWebSocket.h"

@interface TiApp (globalSocket)
+ (SRWebSocket *) WS;
+ (BOOL) connected;

+ (SRWebSocket *) WS: (SRWebSocket *) socket;
+ (BOOL) connected: (BOOL) state;

@end
