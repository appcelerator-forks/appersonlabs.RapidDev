//
//  TiProxy+HackedValueForUndefinedKey.h
//  rapid
//
//  Created by Matt Apperson on 1/1/14.
//
//
#import "JRSwizzle.h"
#import "TiProxy.h"

@interface TiProxy (HackedValueForUndefinedKey)
- (id)HackValueForUndefinedKey_TiProxy:(NSString *)key;
@end
