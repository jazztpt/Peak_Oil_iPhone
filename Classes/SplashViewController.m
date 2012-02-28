//
//  SplashViewController.m
//  PeakOil
//
//  Created by Anna Callahan on 10/28/11.
//  Copyright 2011 SuperIndieFilms. All rights reserved.
//

#import "SplashViewController.h"

#import "Constants.h"
#import "DataChoicesTableViewController.h"


@implementation SplashViewController

@synthesize spinner = _spinner;
@synthesize goOnButton = _goOnButton;
@synthesize dataDict = _dataDict;
@synthesize apiManager = _apiManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.apiManager = nil;
    self.dataDict = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"loaded splash screen");
    
    [_spinner startAnimating];
    self.goOnButton.enabled = NO;
    
//    self.apiManager = [[[APIManager alloc] init] autorelease];
//    _apiManager.delegate = self;
//    [_apiManager getDataByType:kAPIKeyThemes];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasBeenOpened"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) goOnToDataChoices
{
    DataChoicesTableViewController* dataChoicesVC = [[[DataChoicesTableViewController alloc] initWithNibName:@"DataChoicesTableViewController" bundle:nil] autorelease];
    dataChoicesVC.dataArray = [self.dataDict objectForKey:@"dataArray"];
    dataChoicesVC.tableHeaderString = [self.dataDict objectForKey:@"tableTitle"];
    dataChoicesVC.level = 0;
    
//    TODO ************** bug
    
    self.goOnButton.enabled = YES;
    [self.navigationController pushViewController:dataChoicesVC animated:YES];
}

#pragma APIManagerDelegate

-(void) apiManager:(APIManager*)apiManager getDataCallback:(NSDictionary*)dataDict
{
    [_spinner stopAnimating];
    
    self.dataDict = dataDict;
    
    [self goOnToDataChoices];
}

-(void) apiManager:(APIManager*)apiManager requestDidFailWithError:(NSError*)error
{
    NSLog(@"Splash VC, apimgr request failed");
}

@end
