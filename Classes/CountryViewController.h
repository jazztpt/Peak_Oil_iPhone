//
//  CountryViewController.h
//  PeakOil
//
//  Created by Anna Callahan on 10/2/11.
//  Copyright 2011 SuperIndieFilms. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "APIManager.h"


@interface CountryViewController : UIViewController <APIManagerDelegate> {
    
    UIView* _splashView;
    UIView* _switchingView;
    
    UILabel* mazamaScienceLabel;
    UILabel* peakOilLabel;
    
    UIImageView* _imageView;
    UIBarButtonItem* _previousButton;
    UIBarButtonItem* _showInfoButton;
    UIBarButtonItem* _nextButton;
    UIActivityIndicatorView* _spinner;
    
    NSTimer* _splashViewTimer;
    
    NSArray* _countriesArray;
    int _countryIndex;
    
    BOOL reloadImage;
    
    APIManager* _apiManager;
    ASIHTTPRequest* _currentImageRequest;
}

@property (nonatomic, retain) IBOutlet UIView* splashView;
@property (nonatomic, retain) IBOutlet UIView* switchingView;
@property (nonatomic, retain) IBOutlet UILabel* mazamaScienceLabel;
@property (nonatomic, retain) IBOutlet UILabel* peakOilLabel;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* previousButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* showInfoButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* nextButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* spinner;

@property (nonatomic, retain) NSArray* countriesArray;
@property int countryIndex;

@property (nonatomic, retain) APIManager* apiManager;
@property (nonatomic, retain) ASIHTTPRequest* currentImageRequest;


-(IBAction) previousButtonTapped;
-(IBAction) showInfoButtonTapped;
-(IBAction) listButtonTapped;
-(IBAction) settingsButtonTapped;
-(IBAction) nextButtonTapped;

@end
