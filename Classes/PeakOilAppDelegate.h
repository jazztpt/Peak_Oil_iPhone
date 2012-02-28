//
//  PeakOilAppDelegate.h
//  PeakOil
//
//  Created by Anna Callahan on 4/24/11.
//  Copyright 2011 iPhoneConcept. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "CountryViewController.h"

@interface PeakOilAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    CountryViewController *countryViewController;

@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CountryViewController *countryViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end

