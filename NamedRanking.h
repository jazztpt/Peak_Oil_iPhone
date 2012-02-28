//
//  NamedRanking.h
//  PeakOil
//
//  Created by Anna Callahan on 10/22/11.
//  Copyright (c) 2011 SuperIndieFilms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Country, Theme;

@interface NamedRanking : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * jsonUrlSuffix;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) Theme * Theme;
@property (nonatomic, retain) Country * Countries;

@end
