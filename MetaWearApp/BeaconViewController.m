//
//  BeaconViewController.m
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/15/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import "BeaconViewController.h"
#import "AppDelegate.h"

@implementation BeaconViewController

@synthesize turnOffButton, turnOnButton, metawearAPI;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"iBeacon";
        
        self.metawearAPI = [[MetaWearAPI alloc] init];
        self.metawearAPI.delegate = self;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"iBeacon";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        self.turnOnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.turnOnButton addTarget:self
                         action:@selector(turnOn)
               forControlEvents:UIControlEventTouchUpInside];
        [self.turnOnButton setTitle:@"Turn On iBeacon" forState:UIControlStateNormal];
        self.turnOnButton.frame = CGRectMake(20.0, 100.0, 300.0, 40.0);
        [self.view addSubview:self.turnOnButton];
        
        self.turnOffButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.turnOffButton addTarget:self
                         action:@selector(turnOff)
               forControlEvents:UIControlEventTouchUpInside];
        [self.turnOffButton setTitle:@"Turn Off iBeacon" forState:UIControlStateNormal];
        self.turnOffButton.frame = CGRectMake(20.0, 200.0, 300.0, 40.0);
        [self.view addSubview:self.turnOffButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.metawearAPI = [[MetaWearAPI alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.metawearAPI = appDelegate.metawearAPI;
    self.metawearAPI.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)turnOn
{
    [self.metawearAPI  enableBeaconMode];
}

- (void)turnOff
{
    [self.metawearAPI disableBeaconMode];
}

-(void) connectionFailed:(NSError *)error ForDevice:(CBPeripheral *)device
{
    CBUUID *mw =[CBUUID UUIDWithString:@"326A9000-85CB-9195-D9DD-464CFBBAE75A"];
    [self.metawearAPI beginScan:mw];
}

-(void) disconnectionSuccessForDevice:(CBPeripheral *)device
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Disconnected" message:@"Disconnection Success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

-(void) disconnectionFailed:(NSError *)error ForDevice:(CBPeripheral *)device
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Disconnected" message:@"Disconnection Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

@end
