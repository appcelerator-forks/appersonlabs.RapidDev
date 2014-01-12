//
//  TiProxy+HackedValueForUndefinedKey.m
//  rapid
//
//  Created by Matt Apperson on 1/1/14.
//
//
#import "TiComplexValue.h"
#import "TiProxy+HackedValueForUndefinedKey.h"

@implementation TiProxy (HackedValueForUndefinedKey)
+(void)load {
    NSError *error = nil;
    if(![self jr_swizzleMethod:@selector(valueForUndefinedKey:) withMethod:@selector(HackValueForUndefinedKey_TiProxy:) error:&error]) {
        NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
}
- (id)HackValueForUndefinedKey_TiProxy:(NSString *)key
{
    @try {
        id result = [self HackValueForUndefinedKey_TiProxy: key];
        if ( result && result != (id)[NSNull null] && [result isKindOfClass:[NSString class]] && key && [key rangeOfString:@"image" options:NSCaseInsensitiveSearch].location != NSNotFound && [result rangeOfString:@"file://" options:NSCaseInsensitiveSearch].location == NSNotFound ) {
            
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"/Resources"];
            filePath = [filePath stringByAppendingPathComponent:(NSString *)[NSString stringWithString:result]];
            
            NSURL *fullPath = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:[fullPath path]]){
                result = [NSString stringWithFormat:@"file://%@", [fullPath absoluteString]];
            } else {
                result = result;
            }
        }
        return result;
    } @catch (NSException* e) {
        NSLog(@"%@", e);
        NSLog(@"Error loading resource: %@", key);
        return NULL;
    }
	
}
@end
