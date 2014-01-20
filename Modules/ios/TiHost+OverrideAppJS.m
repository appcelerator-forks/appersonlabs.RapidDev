//
//  TiHost+OverrideAppJS.m
//  rapid
//
//  Created by Matt Apperson on 1/17/14.
//
//

#import "TiHost+OverrideAppJS.h"
#import "TiApp+globalSocket.h"
#import "ComAppersonlabsRapiddevModule.h"

@implementation TiHost (OverrideAppJS)
+(void)load {
    NSError *error = nil;
    if(![self jr_swizzleMethod:@selector(startURL) withMethod:@selector(startURLRapidDev) error:&error]) {
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
}

-(NSURL*)startURLRapidDev
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (defaults) {
        NSString *injectedScript = [[TiApp tiAppProperties] stringForKey:@"injectedScript"];
        if(injectedScript) {
            NSURL *bundleRoot = [[NSBundle mainBundle] bundleURL];
            NSURL *url = [TiUtils toURL:injectedScript relativeToURL:bundleRoot];
            [defaults removeObjectForKey:@"injectedScript"];
            [defaults synchronize];
            
            return url;
        }
        
        // Something here to allow flor straight up code to be injected
    }
	return [self startURLRapidDev];
}

@end
