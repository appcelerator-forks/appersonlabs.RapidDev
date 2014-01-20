/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiApp.h"
#import "TiModule.h"
#import "TiProxy.h"
#import "AppModule.h"

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SCASE(str)                       if ([__s__ hasPrefix:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT
#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@interface ComAppersonlabsRapiddevModule : TiModule <NSObject>
{
}
+(NSString*) moduleAssets;
+(NSURL*) moduleBaseURL;


@end
