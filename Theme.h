//
//  Theme.h
//  PeakOil
//
//  Created by Anna Callahan on 10/22/11.
//  Copyright (c) 2011 SuperIndieFilms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NamedRanking;

@interface Theme : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NamedRanking * NamedRankings;

@end
