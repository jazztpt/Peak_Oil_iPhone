//
//  SplashViewController.h
//  PeakOil
//
//  Created by Anna Callahan on 10/28/11.
//  Copyright 2011 SuperIndieFilms. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "APIManager.h"


@interface SplashViewController : UIViewController <APIManagerDelegate> {
    UIActivityIndicatorView* _spinner;
    UIButton* _goOnButton;
    NSDictionary* _dataDict;
    
    APIManager* _apiManager;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, retain) IBOutlet UIButton* goOnButton;
@property (nonatomic, retain) NSDictionary* dataDict;
@property (nonatomic, retain) APIManager* apiManager;

- (IBAction) goOnToDataChoices;

@end
