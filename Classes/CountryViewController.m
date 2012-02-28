//
//  CountryViewController.m
//  PeakOil
//
//  Created by Anna Callahan on 10/2/11.
//  Copyright 2011 SuperIndieFilms. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

//#import "Constants.h"
#import "CountryViewController.h"
#import "Country.h"
#import "DataChoicesTableViewController.h"
#import "DataManager.h"
#import "ListViewController.h"
#import "NamedRanking.h"
//#import "SplashViewController.h"


@interface CountryViewController (Private)
-(void) fadeSplashView;
-(void) loadImage;
-(void) transitionViewToIndex:(int)index forward:(BOOL)forward;
@end


@implementation CountryViewController

@synthesize splashView = _splashView;
@synthesize switchingView = _switchingView;
@synthesize mazamaScienceLabel, peakOilLabel;
@synthesize imageView = _imageView;
@synthesize showInfoButton = _showInfoButton;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;
@synthesize spinner = _spinner;
@synthesize countriesArray = _countriesArray;
@synthesize countryIndex = _countryIndex;
@synthesize apiManager = _apiManager;
@synthesize currentImageRequest = _currentImageRequest;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"country view index %d did receive MEMORY WARNING", _countryIndex);
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadImage];
    
    // start the splash view timer
    _splashViewTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeSplashView) userInfo:nil repeats:NO];
    
    // we'll use this later
    self.apiManager = [[[APIManager alloc] init] autorelease];
    _apiManager.delegate = self;
    
    // check if the json files have been saved to docs folder;
    // if not, save these files from main bundle into docs folder (first time setup)
    NSString* DOCSFOLDER = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *mainBundlePath = [[NSBundle mainBundle] pathForResource:@"themes" ofType:@"json"];
    NSString *docsPath = [DOCSFOLDER stringByAppendingPathComponent:kAPIKeyThemes];
    NSLog(@"main bundle path: %@", mainBundlePath);
    NSLog(@"docsfolder path: %@", docsPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if (![fileManager fileExistsAtPath:docsPath]) 
    {        
        NSError* error = nil;
        [fileManager copyItemAtPath:mainBundlePath toPath:docsPath error:&error];
        if (error != nil) {
            NSLog(@"%@", error);
        }
        
        // copy the mainbundle json files for namedRankings
        NSDictionary* dataDict = [_apiManager loadInternalJsonFile:kAPIKeyThemes];
        NSArray* rankingsArray = [dataDict objectForKey:@"dataArray"];
        
        for (NSDictionary* rankingDict in rankingsArray) {
            error = nil;
            NSString* fileName = [rankingDict objectForKey:@"jsonUrlSuffix"];
            // make sure this is just the filename, no extension
            fileName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
                        
            mainBundlePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
            docsPath = [DOCSFOLDER stringByAppendingPathComponent:fileName];
            [fileManager copyItemAtPath:mainBundlePath toPath:docsPath error:&error];
            if (error != nil) {
                NSLog(@"%@, %@", error, [error description]);
            }
        }

    }
    
    // read named rankings from docsfolder and save to database
    NSDictionary* dataDict = [_apiManager loadInternalJsonFile:kAPIKeyThemes];
    NSArray* rankingsArray = [dataDict objectForKey:@"dataArray"];
    [[DataManager sharedDataManager] addToDBObjects:rankingsArray ofClass:@"NamedRanking"];
    
    // now grab the new json files from the server and store them in the docsfolder
    [_apiManager getFromServerFileNamed:kAPIKeyThemes];
    for (NSString* fileName in rankingsArray) {
        [_apiManager getFromServerFileNamed:fileName];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (reloadImage) {
        reloadImage = NO;
        [self loadImage];
    }

}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"countries array count: %d", self.countriesArray.count);
    NSLog(@"named ranking id: %@", (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"namedRankingId"]);
    if ([(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"namedRankingId"] length] < 2) {
        [self settingsButtonTapped];
    }
    else if (self.countriesArray.count < 1) {
        [self listButtonTapped];
    }
}

// this is called when the timer fires
-(void) fadeSplashView {    
    [UIView beginAnimations:@"fadeOutSplash" context:_splashView];
    _splashView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void) loadImage
{
    Country* currentCountry = [self.countriesArray objectAtIndex:_countryIndex];
    
    if (currentCountry == nil) {
        mazamaScienceLabel.hidden = NO;
        peakOilLabel.hidden = NO;
    } else {
        mazamaScienceLabel.hidden = YES;
        peakOilLabel.hidden = YES;
    }
    
    
    NSString* imageName = currentCountry.imageName;
    
    if (_countryIndex == 0) {
        self.previousButton.enabled = NO;
    } else {
        self.previousButton.enabled = YES;
    }
    if (_countryIndex == [self.countriesArray count] - 1) {
        self.nextButton.enabled = NO;
    } else {
        self.nextButton.enabled = YES;
    }
    
	
	if (imageName != nil) {
		self.apiManager = [[[APIManager alloc] init] autorelease];
		_apiManager.delegate = self;
		NSDictionary* dictionary = [_apiManager fetchImage:imageName];
		
		self.currentImageRequest = [dictionary objectForKey:@"request"];
		
		UIImage* image = [dictionary objectForKey:@"image"];
		
		
		if (!image) {
			image = [UIImage imageNamed:@"default_cell_image.png"];
			[_spinner startAnimating];
		}
        
		
		self.imageView.image = image;
	}
	else {
		[_spinner stopAnimating];
	}

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setCurrentImageRequest:(ASIHTTPRequest *)request
{
	_currentImageRequest.delegate = nil;
	[_currentImageRequest release];
	_currentImageRequest = [request retain];
}

-(void) setApiManager:(APIManager *)apiMgr
{
	_apiManager.delegate = nil;
	[_apiManager release];
	_apiManager = [apiMgr retain];
}


#pragma User Actions

-(IBAction) previousButtonTapped
{
    [self transitionViewToIndex:_countryIndex-1 forward:NO];    
}

-(IBAction) showInfoButtonTapped
{
    Country* currentCountry = [self.countriesArray objectAtIndex:_countryIndex];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:currentCountry.caption delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(IBAction) listButtonTapped
{
    reloadImage = YES;
    
    ListViewController* listVC = [[[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil] autorelease];
    listVC.countryVC = self;
    [self presentModalViewController:listVC animated:YES];
}

-(IBAction) settingsButtonTapped
{
    reloadImage = YES;
    
    DataChoicesTableViewController* dataChoicesVC = [[[DataChoicesTableViewController alloc] initWithNibName:@"DataChoicesTableViewController" bundle:nil] autorelease];
    
    self.apiManager = [[[APIManager alloc] init] autorelease];
    _apiManager.delegate = self;
    NSDictionary* dataDict = [_apiManager loadInternalJsonFile:kAPIKeyThemes];
    
    dataChoicesVC.dataArray = [dataDict objectForKey:@"dataArray"];
    dataChoicesVC.tableHeaderString = [dataDict objectForKey:@"tableTitle"];
    dataChoicesVC.level = 0;
    
//    SplashViewController* splashVC = [[[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil] autorelease];
    UINavigationController* navController = [[[UINavigationController alloc] initWithRootViewController:dataChoicesVC] autorelease];
    [self presentModalViewController:navController animated:YES];
}

-(IBAction) nextButtonTapped
{
    [self transitionViewToIndex:_countryIndex+1 forward:YES];
}

-(void) transitionViewToIndex:(int)index forward:(BOOL)forward
{
    CountryViewController* nextCountryVC = [[CountryViewController alloc] initWithNibName:@"CountryViewController" bundle:nil];
    nextCountryVC.countriesArray = self.countriesArray;
    nextCountryVC.countryIndex = index;
    
    //4. Add the transition in the method that moves to the next view
    // get the view that’s currently showing
    UIView *currentView = self.switchingView;
    // get the the underlying UIWindow, or the view containing the current view
    UIView *mainView = [currentView superview];
    
    UIView *newView = nextCountryVC.view;
    
    // remove the current view and replace with myView1
    [currentView removeFromSuperview];
    [mainView addSubview:newView];    
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:forward ? kCATransitionFromRight : kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[mainView layer] addAnimation:animation forKey:@"SwitchToNextView"];

}


#pragma mark APIManagerDelegate

-(void) apiManager:(APIManager*)apiManager fetchImageCallback:(ASIHTTPRequest*)request
{
	[_spinner stopAnimating];
	
	UIImage* image = [UIImage imageWithData:request.responseData];
	self.imageView.image = image;
}

-(void) apiManager:(APIManager *)apiManager requestDidFailWithError:(NSError *)error
{
	[_spinner stopAnimating];
    // default image?
}

- (void)dealloc
{    
    self.countriesArray = nil;
    self.apiManager = nil;
    self.currentImageRequest = nil;
    
    [super dealloc];
}

@end
