//
//  TiApp+HandleOpenURL.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/24/13.
//
//

#import "KrollBridge+HackedRequire.h"
#import "TiConsole.h"
#import "TiApp+globalSocket.h"
#import "NSString+Base64Additions.h"

@implementation KrollBridge (HackedRequire)

static int maxConnect = 10;

#pragma WebSocket Delegate

-(void)webSocketDidOpen:(SRWebSocket*)webSocket
{
    [TiApp connected: YES];
    maxConnect = 10;
    
    NSLog(@"[RapidDev] Device has connected to your RapidDev server");
}

-(void)webSocket:(SRWebSocket*)webSocket didFailWithError:(NSError*)error
{
    [TiApp connected: NO];
    
    NSLog(@"[RapidDev] Device has disconnected from your RapidDev server due to an error");
    NSLog(@"%@",[error localizedDescription]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RapidDev" message:@"This device has disconnected from your RapidDev server due to an error, please check your device console output for details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    [alert show];
    [alert release];
}

-(void)webSocket:(SRWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(NSString*)reason wasClean:(BOOL)wasClean
{
    [TiApp connected: NO];
    
    NSLog(@"[RapidDev] Device has disconnected from your RapidDev server");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RapidDev" message:@"This device has disconnected from your RapidDev server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    [alert show];
    [alert release];
}

-(void)webSocket:(SRWebSocket*)webSocket didReceiveMessage:(id)data
{
    if([data isKindOfClass:[NSString class]]) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray* parts = [(NSString *)data componentsSeparatedByString:@"|"];

        if (defaults) {
            [defaults setObject:[parts lastObject] forKey:@"[RapidDev]lastHash"];
            [defaults synchronize];
        }
        
        SWITCH (data) {
            SCASE (@"update-file") {
                NSData *decodedData;
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:(NSString *)[NSString stringWithString:[parts objectAtIndex:1]]];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
                NSError* error;
                if ([(NSString*)[parts objectAtIndex:2] isBase64Data]) {
                    decodedData = [[NSData alloc] initWithBase64EncodedString:[parts objectAtIndex:2] options:0];
                } else {
                    NSLog(@"[RapidDev] Invalid data receved from the RapidDev server");
                }
                if(![decodedData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
                    NSLog(@"[RapidDev] Error writing file: %@", error);
                } else {
                    NSLog(@"[RapidDev] Update receved... reloading the app now...");
                    [self evalJSWithoutResult: @"Ti.App._restart();"];
                }
                break;
            }
            SCASE (@"remove-file") {
                NSString *path = (NSString *) [[NSString stringWithString:[parts objectAtIndex:1]] retain];

                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent: path];

                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error;
                if ([fileManager fileExistsAtPath:filePath]) {
                    if (![fileManager removeItemAtPath:filePath error:&error]) {
                        
                    }NSLog(@"[RapidDev] Error: %@", [error localizedDescription]);
                    
                    NSLog(@"[RapidDev] Update receved... reloading the app now...");
                    [self evalJSWithoutResult: @"Ti.App._restart();"];
                }

                break;
            }
            SCASE (@"take-screen") {
                NSLog(@"[RapidDev] Take a screenshot... oops not yet... still working on this feature");
                
                break;
            }
            SCASE (@"full-reload-error") {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RapidDev" message:@"This app is not in sync with the source code on your development machine, RapidDev is unable to recover. Please reinstall the app using Titanium to fix this." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
                [alert show];
                [alert release];
                break;

            }
            SCASE (@"full-reload-module") {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RapidDev" message:@"The app requires changes to the modules used. Please reinstall the app using Titanium." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
                [alert show];
                [alert release];
                break;

            }
            SCASE (@"update-hash") {
                break;
            }
            DEFAULT {
                NSLog(@"[RapidDev] Unknown command receved: %@", data);
                break;
            }
        }
    } else {
        NSLog(@"Unknown error caused by unknown message:");
        NSLog(@"%@", data);
    }
    
}
-(id)reload
{
    if ((![TiApp WS] || ![TiApp connected]) && maxConnect > 0) {
        maxConnect = maxConnect - 1;
        NSLog(@"[RapidDev] (re)Connecting to the RapidDev server...");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastHash = [defaults stringForKey:@"[RapidDev]lastHash"];
        NSString *buildTime = [defaults stringForKey:@"[RapidDev]buildTime"];
        
        [TiApp WS].delegate = nil;
        [[TiApp WS] close];
        
        
        // will return string value for key
        NSString* _url = [[TiApp tiAppProperties] stringForKey:@"rapiddevURL"];
        NSString* buildTimeNew = [[TiApp tiAppProperties] stringForKey:@"rapiddevBuildTimeNew"];
        
        if(buildTimeNew) {
            
    // This makes sure the iOS simulator never freaks out over JS/assets not being "in sync" because it always is
    #if !TARGET_IPHONE_SIMULATOR
            // If the app was just installed/upgraded then clean things up
            if (defaults && ![buildTimeNew isEqual: @""] && ![buildTimeNew isEqual: buildTime]) {
    #endif
                NSLog(@"[RapidDev] Clearing RapidDev cache");
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
               
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent: @"Resources"];
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];

                [defaults setObject:buildTimeNew forKey:@"[RapidDev]buildTime"];
                [defaults removeObjectForKey:@"[RapidDev]rapiddevBuildTimeNew"];
                [defaults removeObjectForKey:@"[RapidDev]lastHash"];
                lastHash = @"";

                [defaults synchronize];
    #if !TARGET_IPHONE_SIMULATOR
           }
    #endif

            if(!_url) {
                _url = [NSString stringWithFormat:@"ws://127.0.0.1:8033/%@/iphone/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"], lastHash];
            } else {
                _url = [NSString stringWithFormat:@"ws://%@:8033/%@/iphone/%@", _url, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"], lastHash];
            }
            
            @try {
                [TiApp WS: [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: _url]]]];
                [TiApp WS].delegate = self;
                
                [[TiApp WS] open];
            }
            @catch (NSException *exception) {
                NSLog(@"");
            }
            
        }
    }
}
+(void)load {
    NSError *error = nil;
    if(![self jr_swizzleMethod:@selector(boot:url:preload:) withMethod:@selector(hackedboot:url:preload:) error:&error]) {
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
}
- (void)hackedboot:(id)callback url:(NSURL*)url_ preload:(NSDictionary*)preload_
{
    [self hackedboot: callback url: url_ preload: preload_];
    
    if([self respondsToSelector:@selector(reload)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reload)
                                                     name:kTiResumedNotification
                                                   object:nil];
    }
    
}
@end
