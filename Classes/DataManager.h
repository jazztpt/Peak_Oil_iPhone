#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kFinishedImportingObjectsNotification	@"finishedImportingObjects"


@interface DataManager : NSObject {
	
	NSManagedObjectContext *_moc;
}


+(DataManager*) sharedDataManager;

// retrieving from db
-(NSArray*) getAllObjects:(NSString*)classString sortedBy:(NSSortDescriptor*)sortDescriptor withPredicate:(NSPredicate*)predicate;
-(id) getObject:(NSString*)classString withPredicate:(NSPredicate*)predicate;
-(UIImage*) getImageWithName:(NSString*)imageName;

// adding to db
-(void) addToDBObjects:(NSArray*)objectsArray ofClass:(NSString*)classString;

-(NSManagedObjectContext*) getMoc;

@end
