//
//  TiApp+HandleOpenURL.h
//  gigya
//
//  Created by Paul Mietz Egli on 11/24/13.
//
//

#import "TiApp.h"
#import <Foundation/Foundation.h>
#import "Bridge.h"
#import "Ti.h"
#import "TiEvaluator.h"
#import "TiProxy.h"
#import "KrollContext.h"
#import "KrollObject.h"
#import "TiModule.h"
#include <libkern/OSAtomic.h>
#import "TiModule.h"
#import "SRWebSocket.h"
#import "TiProxy.h"
#import "AppModule.h"
#import "JRSwizzle.h"
#import "KrollBridge.h"


#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SCASE(str)                       if ([__s__ hasPrefix:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT
#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]


@interface KrollBridge (HackedRequire) <SRWebSocketDelegate>

@end
