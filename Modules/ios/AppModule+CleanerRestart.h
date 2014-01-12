//
//  AppModule+CleanerRestart.h
//  rapid
//
//  Created by Matt Apperson on 1/11/14.
//
//

#import "JRSwizzle.h"
#import "AppModule.h"

@interface AppModule (CleanerRestart)
//-(void)_restart:(id)unused;
-(void)_resumeRestart:(id)unused;
@end
