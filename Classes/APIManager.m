//
//  APIManager.m
//
//  Created by Anna Callahan on 4/22/11.
//  Copyright 2011 iPhoneConcept.
//

#import "APIManager.h"

#import "ASIDownloadCache.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
//#import "NSString+SBJSON.h"


#define kAPIKeyKey						@"apiKey"
#define kBaseAPIKey						@"http://mazamascience.com/iPhone/PeakOil/"
#define kAPIKeyImage                    @"image"
#define kAPIKeyAuthenticate				@"authenticate"


@implementation APIManager

@synthesize delegate	= _delegate;

- (void) authenticateWithEmail:(NSString *)email password:(NSString *)password
{
	NSString* urlString = [NSString stringWithFormat:@"%@%@", kBaseAPIKey, kAPIKeyAuthenticate];
	
	NSURL *url = [NSURL URLWithString:urlString];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:email forKey:@"email"];
	[request setPostValue:password forKey:@"password"];
	[request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"device_id"];

	[request setUserInfo:[NSDictionary dictionaryWithObject:kAPIKeyAuthenticate forKey:kAPIKeyKey]];
	[request setDelegate:self];
	
	[self retain];
	[request startAsynchronous];
	
}

// type can be "themes.json" or [[NSUserDefaults standardUserDefaults] objectForKey:@"namedRankingId"]], it's the full file name
- (void) getFromServerFileNamed:(NSString*)fileName;
{
//    // at this time, we are just reading from the built-in named rankings.  
//    if ([type isEqualToString:kAPIKeyThemes]) {
////        [self tempMethodForResource:@"sampleThemes"];
//        NSLog(@"WARNING: tried to load temp method for resource (apimanager getDataByType)");
//    } else {
    
        NSString* urlString = [NSString stringWithFormat:@"%@%@", kBaseAPIKey, fileName];
        NSURL* url = [NSURL URLWithString:urlString];
        
        NSLog(@"downloading data from: %@", url);
        
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
        
        [request setUserInfo:[NSDictionary dictionaryWithObject:fileName forKey:kAPIKeyKey]];
        [request setDelegate:self];
        
        [self retain];
        [request startAsynchronous];   
//    }
    
    //temp
//    [self tempMethod];
}

#pragma mark Images

// Extracts the image path from a completed request and loads it from disk.
+ (UIImage*)imageWithRequest:(ASIHTTPRequest*)request 
{
	NSData* data = [NSData dataWithData:[request responseData]];
	return [UIImage imageWithData:data];
}

// Performs fetch of image, immediately alerting delegate if request was cached.
- (NSDictionary*)fetchImage:(NSString*)imageName
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
		// Retina display
		NSArray* nameComponents = [imageName componentsSeparatedByString:@"."];
		imageName = [NSString stringWithFormat:@"%@@2x.%@", [nameComponents objectAtIndex:0], [nameComponents objectAtIndex:1]];
		NSLog(@"new image name: %@", imageName);
    }
	
	NSURL* imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseAPIKey, imageName]];
    
	if (!imageUrl)
		return nil;
    
    NSLog(@"API mgr fetching image from: %@", imageUrl);
	
	
	ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:imageUrl];
	[request setUserInfo:[NSDictionary dictionaryWithObject:kAPIKeyImage forKey:kAPIKeyKey]];
	[request setDownloadCache:[ASIDownloadCache sharedCache]];
	[request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
	[request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
	
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	
	[dictionary setObject:request forKey:@"request"];
	
	ASIDownloadCache* sharedCache = [ASIDownloadCache sharedCache];
	NSString* path = [sharedCache pathToStoreCachedResponseDataForRequest:request];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) 
	{
		UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
		if (image) {
			[dictionary setObject:image forKey:@"image"];
		}
	}	
	else 
	{
		[request setDelegate:self];
		[self retain];
		[request startAsynchronous];
		
	}
	
	return dictionary;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	if ( error ) {		
		[self didFailWithError:error];
		return;
	}
	else if ([[request userInfo] objectForKey:kAPIKeyKey] != nil) {
		NSString *responseString = [request responseString];
		
		//	NSString *httpResponse = [[NSString alloc] initWithString: encoding:NSUTF8StringEncoding];
		SBJsonParser *JSONParser = [[SBJsonParser alloc] init];
		NSError *jsonError = nil;
		id jsonObj = [JSONParser objectWithString:responseString error:&jsonError];
		
		[JSONParser release];
		
		////			id jsonObj = [responseString JSONValue];
        
		if ([[[request userInfo] objectForKey:kAPIKeyKey] isEqualToString:kAPIKeyImage]) {

            if (_delegate != nil && [_delegate respondsToSelector:@selector(apiManager:fetchImageCallback:)]) {
                [_delegate apiManager:self fetchImageCallback:request];
            }

			[self release];
			return;
		}
		NSLog(@"requestfinished: %@", responseString);
		
		if ( jsonObj == nil ) {
			
			// TODO - call server with JSON errors
			//
			
			[self didFailWithError:jsonError];				
			return;
		}
		
		if ([[[request userInfo] objectForKey:kAPIKeyKey] isEqualToString:kAPIKeyAuthenticate]) {
			if (_delegate != nil && [_delegate respondsToSelector:@selector(apiManager:authenticationReceived:)]) {
				[_delegate apiManager:self authenticationReceived:jsonObj];
			}
            
		}
		
		else {
            // !!!!!!!!!!!!!!!!!!!!!!!! here !!!!!!!!!!!!!!!!!!!!!!!!!
            // it's probably one of the json files
            // we're saving these files straight to the docsfolder
            NSString* DOCSFOLDER = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [DOCSFOLDER stringByAppendingPathComponent:[[request userInfo] objectForKey:kAPIKeyKey]];
            NSError* error;
            [responseString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            if (error) {
                NSLog(@"error writing server json to docsfolder file, %@ - %@", error, [error description]);
            }
            
            NSArray* list = [jsonObj objectForKey:@"list"];
			if (_delegate != nil && [_delegate respondsToSelector:@selector(apiManager:getDataCallback:)]) {                
                [_delegate apiManager:self getDataCallback:jsonObj];
				
			}
		}

	}
		
	[self release];
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog( @"HTTP Request Failed: %@", error );
	
	[self didFailWithError:error];
}

- (void) didFailWithError:(NSError *) error
{
	if (_delegate != nil && [_delegate respondsToSelector:@selector(apiManager:requestDidFailWithError:)]) {
		[_delegate apiManager:self requestDidFailWithError:error];
	}
}

//-(void) tempMethodForResource:(NSString*)resourceString {
//    //temp - read a static file from main bundle
//    NSString *mockJsonPath = [[NSBundle mainBundle] pathForResource:resourceString ofType:@"json"];
//    NSError* error = nil;
//    NSString *mockJsonString = [NSString stringWithContentsOfFile:mockJsonPath encoding:NSUTF8StringEncoding error:&error];
//    
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    id jsonObj = [parser objectWithString:mockJsonString];
//    
//    NSLog(@"mock json object: %@", jsonObj);
//    
//    if (_delegate != nil && [_delegate respondsToSelector:@selector(apiManager:getDataCallback:)]) {                
//        [_delegate apiManager:self getDataCallback:jsonObj];
//        
//    }
//}

-(NSDictionary*) loadInternalJsonFile:(NSString*)fileName {
    
    // read a static file from docs folder
    NSString* docsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* localJsonPath = [docsFolder stringByAppendingPathComponent:fileName];
//    NSString *localJsonPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSError* error = nil;
    NSString *localJsonString = [NSString stringWithContentsOfFile:localJsonPath encoding:NSUTF8StringEncoding error:&error];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id jsonObj = [parser objectWithString:localJsonString];
    
    NSLog(@"local json object: %@", jsonObj);
    
    return (NSDictionary*)jsonObj;
}

-(void) dealloc
{
	[super dealloc];
}

@end
