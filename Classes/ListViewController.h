//
//  ListViewController.h
//  PeakOil
//
//  Created by Anna Callahan on 4/24/11.
//  Copyright 2011 iPhoneConcept. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "APIManager.h"
#import "CountryViewController.h"


@interface ListViewController : UIViewController <NSFetchedResultsControllerDelegate, APIManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UITableView* _tableView;
    UIActivityIndicatorView* _spinner;
	NSArray* _itemsInTableArray;
    CountryViewController* _countryVC;
    UINavigationItem* _navItem;
    
	
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    
    APIManager* _apiManager;
    
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, retain) NSArray* itemsInTableArray;
@property (nonatomic, retain) CountryViewController* countryVC;
@property (nonatomic, retain) IBOutlet UINavigationItem* navItem;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) APIManager* apiManager;

@end
