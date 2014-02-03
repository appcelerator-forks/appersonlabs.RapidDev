/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComAppersonlabsRapiddevModule.h"
#import <objc/message.h>
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "AppModule.h"
#import "JRSwizzle.h"

@implementation ComAppersonlabsRapiddevModule

static NSString* moduleAssets;
+ (NSString*) moduleAssets
{ @synchronized(self) { return moduleAssets; } }
+ (void) setModuleAssets:(NSString*)val
{ @synchronized(self) { moduleAssets = val; } }

static NSURL* moduleBaseURL;
+ (NSURL*) moduleBaseURL
{ @synchronized(self) { return moduleBaseURL; } }
+ (void) setModuleBaseURL:(NSURL*)val
{ @synchronized(self) { moduleBaseURL = val; } }

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"6c572bf6-dabd-4878-87ec-eca01bad8000";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
    ComAppersonlabsRapiddevModule.moduleBaseURL = [self _baseURL];
    
    return @"com.appersonlabs.rapiddev";
}
@end
