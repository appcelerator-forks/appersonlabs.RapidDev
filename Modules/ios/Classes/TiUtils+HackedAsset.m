//
//  TiUtils+HackedAsset.m
//  rapid
//
//  Created by Matt Apperson on 1/6/14.
//
//

#import "TiUtils+HackedAsset.h"

@implementation TiUtils (HackedAsset)
+(NSData *)loadAppResource:(NSURL*)url
{
	BOOL app = [[url scheme] hasPrefix:@"app"];
	if ([url isFileURL] || app)
	{
		BOOL leadingSlashRemoved = NO;
		NSString *urlstring = [[url standardizedURL] path];
		NSString *resourceurl = [[NSBundle mainBundle] resourcePath];
		NSRange range = [urlstring rangeOfString:resourceurl];
		NSString *appurlstr = urlstring;
        
		if (range.location!=NSNotFound)
		{
			appurlstr = [urlstring substringFromIndex:range.location + range.length + 1];
		}
		if ([appurlstr hasPrefix:@"/"])
		{
			leadingSlashRemoved = YES;
			appurlstr = [appurlstr substringFromIndex:1];
		}

        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"/Resources"];
        filePath = [filePath stringByAppendingPathComponent:(NSString *)[NSString stringWithString:appurlstr]];
        
        NSURL *fullPath = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[fullPath path]]){
            return [fileManager contentsAtPath:[fullPath path] ];
        }
        
		static id AppRouter;
		if (AppRouter==nil)
		{
			AppRouter = NSClassFromString(@"ApplicationRouting");
		}
		if (AppRouter!=nil)
		{
			appurlstr = [appurlstr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
			if ([appurlstr characterAtIndex:0]=='/')
			{
				appurlstr = [appurlstr substringFromIndex:1];
			}
			DebugLog(@"[DEBUG] Loading: %@, Resource: %@",urlstring,appurlstr);
            NSLog(@"%@",[[NSString alloc] initWithData:[AppRouter performSelector:@selector(resolveAppAsset:) withObject:appurlstr] encoding:NSUTF8StringEncoding]);
			return [AppRouter performSelector:@selector(resolveAppAsset:) withObject:appurlstr];
		}
	}
	return nil;
}

@end
