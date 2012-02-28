//
//  DataChoicesTableViewController.h
//  PeakOil
//
//  Created by Anna Callahan on 10/28/11.
//  Copyright 2011 SuperIndieFilms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DataChoicesTableViewController : UITableViewController {
    NSArray* _dataArray;
    int _level;
    NSString* _tableHeaderString;
}

@property (nonatomic, retain) NSArray* dataArray;
@property int level;
@property (nonatomic, retain) NSString* tableHeaderString;

@end
