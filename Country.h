//
//  Country.h
//  PeakOil
//
//  Created by Anna Callahan on 10/22/11.
//  Copyright (c) 2011 SuperIndieFilms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NamedRanking;

@interface Country : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * altImageUrl;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NamedRanking * NamedRanking;

@end
