/*
 *  DataManager.m
 *
 *  Created by Anna Callahan on 4/22/11.
 *  Copyright 2011 iPhoneConcept. All rights reserved.
 *
 */


#import <CoreData/CoreData.h>


#import "DataManager.h"

//#import your data model objects here
#import "PeakOilAppDelegate.h"

#import "Country.h"
#import "NamedRanking.h"



@implementation DataManager

static DataManager *sharedDataManager;


+(DataManager*) sharedDataManager
{
	if (sharedDataManager == nil) {
		sharedDataManager = [[DataManager alloc] init];
	}
	return sharedDataManager;
}

-(NSArray*) getAllObjects:(NSString*)classString sortedBy:(NSSortDescriptor*)sortDescriptor withPredicate:(NSPredicate*)predicate
{
	[self getMoc];
	
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:classString inManagedObjectContext:_moc]];
	if (sortDescriptor != nil) {
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	}
	if (predicate != nil) {
		[request setPredicate:predicate];
	}
	
	NSError* error = nil;
	NSArray* objecstArray = [_moc executeFetchRequest:request error:&error];
	
	[request release];
	
	return objecstArray;
}

-(id) getObject:(NSString*)classString withPredicate:(NSPredicate*)predicate
{
	[self getMoc];
	
	id object = nil;
	NSFetchRequest* request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:classString inManagedObjectContext:_moc]];
	[request setPredicate:predicate];
	
	NSError* error = nil;
	NSArray* objectsArray = [_moc executeFetchRequest:request error:&error];
	if (objectsArray.count > 0) {
		object = [objectsArray objectAtIndex:0];
	}
	
	[request release];
	
	return object;
}

-(UIImage*) getImageWithName:(NSString*)imageName
{
	NSString* docsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	NSString* imageFilename = [docsFolder stringByAppendingPathComponent:imageName];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilename]) {
		return [UIImage imageWithContentsOfFile:imageFilename];
	}
	else {
		return [UIImage imageNamed:imageName];
	}
}

#pragma mark -
#pragma mark Adding to DB

-(void) addToDBObjects:(NSArray*)objectsArray ofClass:(NSString*)classString
{
    Class klass = NSClassFromString(classString);

	for (NSDictionary* objectDict in objectsArray) {
		// first check if this object already exists
		NSString* objectID = [objectDict objectForKey:@"id"];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"externalId = %@", objectID];
		
		[self getMoc];
        
        if ([classString isEqualToString:@"Country"]) {
		
            Country* currentObject = [self getObject:classString withPredicate:predicate];
            if (currentObject == nil) {
                currentObject = [[klass alloc] initWithEntity:[NSEntityDescription entityForName:classString inManagedObjectContext:_moc] insertIntoManagedObjectContext:_moc];
            }

            currentObject.name = [objectDict objectForKey:@"name"];
            currentObject.externalId = [objectDict objectForKey:@"id"];
            currentObject.value = [objectDict objectForKey:@"value"];

            currentObject.imageName = [objectDict objectForKey:@"imageName"];
            currentObject.altImageUrl = [objectDict objectForKey:@"altImageUrl"];
            currentObject.caption = [objectDict objectForKey:@"caption"];
            
            if ([[objectDict objectForKey:@"rank"] isKindOfClass:[NSString class]]) {
                NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    //            NSLog(@"rank class = %@, rank = %@", [[objectDict objectForKey:@"rank"] class], [objectDict objectForKey:@"rank"]);
                [numberFormatter setAllowsFloats:NO];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                currentObject.rank = [numberFormatter numberFromString:[objectDict objectForKey:@"rank"]];
                [numberFormatter release];
    //            NSLog(@"currentObject.value = %@;   currentObject.rank = %@", currentObject.value, currentObject.rank);
            } else {
                currentObject.rank = [objectDict objectForKey:@"rank"];
    //            NSLog(@"currentObject.value = %@;   currentObject.rank = %@", currentObject.value, currentObject.rank);
            }
        } else {
            NamedRanking* currentObject = [self getObject:classString withPredicate:predicate];
            if (currentObject == nil) {
                currentObject = [[klass alloc] initWithEntity:[NSEntityDescription entityForName:classString inManagedObjectContext:_moc] insertIntoManagedObjectContext:_moc];
            }
            
            currentObject.title = [objectDict objectForKey:@"title"];
            currentObject.externalId = [objectDict objectForKey:@"id"];
            currentObject.jsonUrlSuffix = [objectDict objectForKey:@"jsonUrlSuffix"];
        }
	}
	
	NSError* error = nil;
	if (![_moc save:&error]) {
		NSLog(@"Error adding objects to db: %@, %@", error, [error userInfo]);
	}
	else {
		NSLog(@"Imported %d objects to db", objectsArray.count);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kFinishedImportingObjectsNotification object:self];
	}

}

-(NSManagedObjectContext*) getMoc
{
	if (_moc == nil) {
		_moc = [[(PeakOilAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] retain];	
	}
	return _moc;
}

@end
