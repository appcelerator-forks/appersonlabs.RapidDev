//
//  TiApp+HandleOpenURL.m
//  gigya
//
//  Created by Paul Mietz Egli on 11/24/13.
//
//

#import "KrollBridge+HackedRequire.h"

@implementation KrollBridge (HackedRequire)

-(id)require:(KrollContext*)kroll path:(NSString*)path
{
	TiModule* module = nil;
	NSData *data = nil;
	NSString *filepath = nil;
    NSString* fullPath = nil;
    NSURL* oldURL = [self currentURL];
    
    // Check the position of the first '/', which will give some information
    // about resource resolution and if the path is absolute.
    //
    // TODO: This violates commonjs 1.1 and there is some ongoing discussion about whether or not
    // it should make a path absolute.
    NSString* workingPath = [oldURL relativePath];
	fullPath = [path hasPrefix:@"/"]?[path substringFromIndex:1]:path;
    
    NSString* moduleID = nil;
    NSString* leadingComponent = [[fullPath pathComponents] objectAtIndex:0];
    BOOL isAbsolute = !([leadingComponent isEqualToString:@"."] || [leadingComponent isEqualToString:@".."]);
    
    
    if (isAbsolute) {
        moduleID = [[fullPath pathComponents] objectAtIndex:0];
    }
    else {
        fullPath = (workingPath != nil) ?
        [[workingPath stringByAppendingPathComponent:[fullPath stringByStandardizingPath]] stringByStandardizingPath] :
        [fullPath stringByStandardizingPath];
        moduleID = [[fullPath pathComponents] objectAtIndex:0];
    }
    
    
	// Now that we have the full path, we can check and see if the module was loaded,
    // and return it if available.
    if (modules!=nil && ![path hasPrefix:@"file:"])
	{
		module = [modules objectForKey:fullPath];
		if (module!=nil)
		{
			return module;
		}
	}
    
    NSRange separatorLocation = [fullPath rangeOfString:@"/"];
    NSString* moduleClassName = [self pathToModuleClassName:moduleID];
    Class moduleClass = NSClassFromString(moduleClassName);
    
    if (moduleClass != nil) {
        NSLog(@"module path: %@", path);
        // We have a module to load resources from! Now we need to determine if
        // it's a base module (which should be cached) or a pure JS resource
        // stored on the module.
        
        module = [modules objectForKey:moduleID];
        
        if (module == nil) {
            module = [[moduleClass alloc] _initWithPageContext:self];
            [module setHost:host];
            [module _setName:moduleClassName];
            [modules setObject:module forKey:moduleID];
            [module autorelease];
        }
        
        // TODO: Support package.json 'main' file identifier which will load instead
        // of module JS. Currently neither iOS nor Android support package information.
        if (separatorLocation.location == NSNotFound) { // Indicates toplevel module
        loadNativeJS:
            if ([module isJSModule]) {
                data = [module moduleJS];
            }
            [self setCurrentURL:[NSURL URLWithString:fullPath relativeToURL:[[self host] baseURL]]];
        }
        else {
            NSString* assetPath = [fullPath substringFromIndex:separatorLocation.location+1];
            // Handle the degenerate case (supported by MW) where we're loading
            // module.id/module.id, which should resolve to module.id and mixin.
            // Rather than create a utility method for this (or C&P if native loading changes)
            // we use a goto to jump into the if block above.
            
            if ([assetPath isEqualToString:moduleID]) {
                goto loadNativeJS;
            }
            NSString* filepath = [assetPath stringByAppendingString:@".js"];
            data = [module loadModuleAsset:filepath];
            // Have to reset module so that this code doesn't get mixed in and is loaded as pure JS
            module = nil;
        }
        
        if (data == nil && isAbsolute) {
            // We may have an absolute URL which tried to load from a module instead of a directory. Fix
            // the fullpath back to the right value, so we can try again.
			fullPath = [path hasPrefix:@"/"]?[path substringFromIndex:1]:path;
        }
        else if (data != nil) {
            // Set the current URL; it should be the fullPath relative to the host's base URL.
            [self setCurrentURL:[NSURL URLWithString:[fullPath stringByDeletingLastPathComponent] relativeToURL:[[self host] baseURL]]];
        }
    }
	
	if (data==nil)
	{
        filepath = [fullPath stringByAppendingString:@".js"];
        NSURL *url_;
        //[RapidDev] for applicationDataDirectory loading

        if (![filepath hasPrefix:@"file:"]) {
            url_ = [NSURL URLWithString:filepath relativeToURL:[[self host] baseURL]];
        } else {
            url_ = [NSURL URLWithString:[filepath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }

        data = [TiUtils loadAppResource:url_];
        
        if (data == nil) {
            data = [NSData dataWithContentsOfURL:url_];
        }
        
        if (data != nil) {
            [self setCurrentURL:[NSURL URLWithString:[fullPath stringByDeletingLastPathComponent] relativeToURL:[[self host] baseURL]]];
        }
	}
    
	// we found data, now create the common js module proxy
	if (data!=nil)
	{
        NSString* urlPath = (filepath != nil) ? filepath : fullPath;
        NSURL *url_;
        //[RapidDev] for applicationDataDirectory loading
        if (![filepath hasPrefix:@"file:"]) {
            url_ = [TiHost resourceBasedURL:urlPath baseURL:NULL];
        } else {
            url_ = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }

       	const char *urlCString = [[url_ absoluteString] UTF8String];
        KrollWrapper* wrapper = nil;
        
        if ([[self host] debugMode] && ![module isJSModule]) {
            TiDebuggerBeginScript([self krollContext],urlCString);
        }
        
		NSString * dataContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		wrapper = [self loadCommonJSModule:dataContents withSourceURL:url_];
        [dataContents release];
		
        if ([[self host] debugMode] && ![module isJSModule]) {
            TiDebuggerEndScript([self krollContext]);
        }
        
		if (![wrapper respondsToSelector:@selector(replaceValue:forKey:notification:)]) {
            [self setCurrentURL:oldURL];
			@throw [NSException exceptionWithName:@"org.testapp.kroll"
                                           reason:[NSString stringWithFormat:@"Module \"%@\" failed to leave a valid exports object",path]
                                         userInfo:nil];
		}
		
		// register the module if it's pure JS
        if (module == nil) {
            module = (id)wrapper;
            
            // [RapidDev] don't cache TiShadow modules
            if (![urlPath hasPrefix:@"file:"]) {
                [modules setObject:module forKey:fullPath];
            }
            if (filepath!=nil && module!=nil)
            {
                // uri is optional but we point it to where we loaded it
                [module replaceValue:[NSString stringWithFormat:@"app://%@",filepath] forKey:@"uri" notification:NO];
            }
        }
        else {
            // For right now, we need to mix any compiled JS on top of a compiled module, so that both components
            // are accessible. We store the exports object and then put references to its properties on the toplevel
            // object.

            TiContextRef jsContext = [[self krollContext] context];
            TiObjectRef jsObject = [wrapper jsobject];
            KrollObject* moduleObject = [module krollObjectForContext:[self krollContext]];
            [moduleObject noteObject:jsObject forTiString:kTiStringExportsKey context:jsContext];
            
            TiPropertyNameArrayRef properties = TiObjectCopyPropertyNames(jsContext, jsObject);
            size_t count = TiPropertyNameArrayGetCount(properties);
            for (size_t i=0; i < count; i++) {
                // Mixin the property onto the module JS object if it's not already there
                TiStringRef propertyName = TiPropertyNameArrayGetNameAtIndex(properties, i);
                if (!TiObjectHasProperty(jsContext, [moduleObject jsobject], propertyName)) {
                    TiValueRef property = TiObjectGetProperty(jsContext, jsObject, propertyName, NULL);
                    TiObjectSetProperty([[self krollContext] context], [moduleObject jsobject], propertyName, property, kTiPropertyAttributeReadOnly, NULL);
                }
            }
            TiPropertyNameArrayRelease(properties);
        }
	}
    
    [self setCurrentURL:oldURL];
	if (module!=nil)
	{
		// spec says you must have a read-only id property - we don't
		// currently support readonly in kroll so this is probably OK for now
		[module replaceValue:path forKey:@"id" notification:NO];
		return module;
	}
	
	@throw [NSException exceptionWithName:@"org.testapp.kroll" reason:[NSString stringWithFormat:@"Couldn't find module: %@",path] userInfo:nil];
}


@end
