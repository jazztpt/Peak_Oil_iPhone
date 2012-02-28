//
//  APIManager.h
//
//  Created by Anna Callahan on 4/22/11.
//  Copyright 2011 iPhoneConcept.
//

/*
 * APIManager makes all calls to the api.  
 * View controllers create an instance of APIManager when they need one and set themselves as the only delegate; 
 * there can be multiple APIManagers around at the same time.
 * When a view controller creates an APIManager, it should be autoreleased.  The APIManager retains itself
 * before making an asynchronous request to prevent a crash in case that request returns after the view controller
 * has been deallocated.  
 * Each time the APIManager calls a delegate, it should check that (_delegate != nil) first in case the view 
 * controller has been deallocated.
 */

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define kAPIKeyThemes                   @"themes.json"
#define kAPIKeyProduction               @"EIA2011OilProductionBbl.json"

@protocol APIManagerDelegate;

@interface APIManager : NSObject {
	id <APIManagerDelegate> _delegate;

}

@property (nonatomic, assign) id <APIManagerDelegate> delegate;

- (void) didFailWithError:(NSError *) error;
- (void) authenticateWithEmail:(NSString *)email password:(NSString *)password;

- (void) getFromServerFileNamed:(NSString*)fileName;
//- (void) getJSONDataFromFile:(NSString*)fileName;

-(NSDictionary*) fetchImage:(NSString*)imageName;
+ (UIImage*)imageWithRequest:(ASIHTTPRequest*)request;

//-(void) tempMethodForResource:(NSString*)resourceString;
-(NSDictionary*) loadInternalJsonFile:(NSString*)fileName;

@end

#pragma mark -
#pragma mark Protocol

@protocol APIManagerDelegate <NSObject>
// all calling objects must implement request did fail
-(void) apiManager:(APIManager*)apiManager requestDidFailWithError:(NSError*)error;

@optional
-(void) apiManager:(APIManager*)apiManager authenticationReceived:(NSDictionary*)authDictionary;
-(void) apiManager:(APIManager*)apiManager getDataCallback:(NSDictionary*)dataDict;
-(void) apiManager:(APIManager*)apiManager fetchImageCallback:(ASIHTTPRequest*)request;

@end