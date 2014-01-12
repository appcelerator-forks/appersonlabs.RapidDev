//
//  AppModule+CleanerRestart.m
//  rapid
//
//  Created by Matt Apperson on 1/11/14.
//
//
#import "TiApp.h"
#import "TiLayoutQueue.h"
#import "AppModule+CleanerRestart.h"

@implementation AppModule (CleanerRestart)
//+(void)load {
//    NSError *error = nil;
//    if(![self jr_swizzleMethod:@selector(_restart:) withMethod:@selector(Hacked_restart:) error:&error]) {
//        NSLog(@"Error: %@ %@", error, [error userInfo]);
//    }
//}
// [UIApplication sharedApplication].idleTimerDisabled = YES;

-(void)_resumeRestart:(id)unused
{
    
    UIApplication * app = [UIApplication sharedApplication];
    TiApp * appDelegate = [TiApp app];
    [TiLayoutQueue resetQueue];
    
    /* End backgrounding */
    [appDelegate endBackgrounding];
    
    /* Disconnect the old view system, intentionally leak controller and UIWindow */
    [[appDelegate window] removeFromSuperview];
    
    /* Disconnect the old modules. */
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    NSMutableArray * delegateModules = (NSMutableArray *)[appDelegate valueForKey:@"modules"];
    for (TiModule * thisModule in delegateModules) {
        [nc removeObserver:thisModule];
    }
    /* Because of other issues, we must leak the modules as well as the runtime */
    [delegateModules copy];
    [delegateModules removeAllObjects];
    
    /* Disconnect the Kroll bridge, and spoof the shutdown */
    [nc removeObserver:[appDelegate krollBridge]];
    NSNotification *notification = [NSNotification notificationWithName:kTiContextShutdownNotification object:[appDelegate krollBridge]];
    [nc postNotification:notification];
    
    /* Begin foregrounding simulation */
    [appDelegate application:app didFinishLaunchingWithOptions:[appDelegate launchOptions]];
    [appDelegate applicationWillEnterForeground:app];
    [appDelegate applicationDidBecomeActive:app];
    /* End foregrounding simulation */
}
@end
