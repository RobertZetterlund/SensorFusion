//
//  AccelerometerViewController.m
//  MetaWearAPI
//
//  Created by Laura Kassovic on 6/4/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//
//  IMPORTANT: Your use of this Software is limited to those specific rights granted under the terms of a
//  software license agreement between the user who downloaded the software, his/her employer (which must be
//  your employer) and MbientLab Inc, (the "License").  You may not use this Software unless you agree to abide
//  by the terms of the License which can be found at www.mbientlab.com/terms. The License limits your use, and
//  you acknowledge, that the Software may not be modified, copied or distributed and can be used solely and
//  exclusively in conjunction with a MbientLab Inc, product.  Other than for the foregoing purpose, you may not
//  use, reproduce, copy, prepare derivative works of, modify, distribute, perform, display or sell this
//  Software and/or its documentation for any purpose.
//  YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE PROVIDED “AS IS” WITHOUT WARRANTY
//  OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY,
//  TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL MBIENTLAB OR ITS LICENSORS
//  BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
//  OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED TO ANY
//  INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF
//  PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT
//  LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
//
//  Should you have any questions regarding your right to use this Software, contact MbientLab Inc, at
//  www.mbientlab.com.
//

#import "AccelerometerViewController.h"
#import "AppDelegate.h"

@implementation AccelerometerViewController

@synthesize unfiltered, filtered, pause, filterLabel;
@synthesize accLabel, lpfLabel, metawearAPI, filterC, standardC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Accelerometer";
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"Accelerometer";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        self.accLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75.0, 280.0, 20.0)];
        self.accLabel.text = @"Accelerometer Data";
        [self.view addSubview:self.accLabel];
        
        self.unfiltered = [[GraphView alloc] initWithFrame:CGRectMake(0, 100.0, 320.0, 112.0)];
        [self.view addSubview:self.unfiltered];
        
        self.lpfLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 225.0, 280.0, 20.0)];
        self.lpfLabel.text = @"Lowpass Filter";
        [self.view addSubview:self.lpfLabel];
        
        self.filtered = [[GraphView alloc] initWithFrame:CGRectMake(0, 250.0, 320.0, 112.0)];
        [self.view addSubview:self.filtered];
        
        NSArray *itemfArray = [NSArray arrayWithObjects: @"Low Pass", @"High Pass", nil];
        self.filterC = [[UISegmentedControl alloc] initWithItems:itemfArray];
        self.filterC.frame = CGRectMake(20, 380.0, 280.0, 30.0);
        self.filterC.selectedSegmentIndex = 1;
        [self.filterC addTarget:self action:@selector(filterSelect:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.filterC];
        
        NSArray *itemsArray = [NSArray arrayWithObjects: @"Standard", @"Adaptive", nil];
        self.standardC = [[UISegmentedControl alloc] initWithItems:itemsArray];
        self.standardC.frame = CGRectMake(20, 425.0, 280.0, 30.0);
        self.standardC.selectedSegmentIndex = 1;
        [self.standardC addTarget:self action:@selector(adaptiveSelect:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.standardC];
        
        self.pause = [[UIButton alloc] initWithFrame:CGRectMake(20, 600.0, 280.0, 21.0)];
        [self.pause addTarget:self action:@selector(pauseOrResume:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.pause];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	isPaused = NO;
	useAdaptive = NO;
	[self changeFilter:[LowpassFilter class]];
	
	[unfiltered setIsAccessibilityElement:YES];
	[unfiltered setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];
    
	[filtered setIsAccessibilityElement:YES];
	[filtered setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.metawearAPI = [[MetaWearAPI alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.metawearAPI = appDelegate.metawearAPI;
    self.metawearAPI.delegate = self;
    
    if ((self.metawearAPI.d.p != NULL) && [self.metawearAPI.d.p isConnected]) {
        [self.metawearAPI enableXYZMotionwithOptions:0];
        [self.metawearAPI enableGlobalAccelerometer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ((self.metawearAPI.d.p != NULL) && [self.metawearAPI.d.p isConnected]) {
        [self.metawearAPI disableXYZMotion];
        [self.metawearAPI disableGlobalAccelerometer];
    }
}

- (void)changeFilter:(Class)filterClass
{
	// Ensure that the new filter class is different from the current one...
	if (filterClass != [filter class])
	{
		// And if it is, release the old one and create a new one.
		filter = [[filterClass alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
		// Set the adaptive flag
		filter.adaptive = useAdaptive;
		// And update the filterLabel with the new filter name.
		filterLabel.text = filter.name;
	}
}

- (void)pauseOrResume:(id)sender
{
	if (isPaused)
	{
		// If we're paused, then resume and set the title to "Pause"
		isPaused = NO;
	}
	else
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
	}
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)filterSelect:(id)sender
{
	if ([sender selectedSegmentIndex] == 0)
	{
		// Index 0 of the segment selects the lowpass filter
		[self changeFilter:[LowpassFilter class]];
	}
	else
	{
		// Index 1 of the segment selects the highpass filter
		[self changeFilter:[HighpassFilter class]];
	}
    
	// Inform accessibility clients that the filter has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)adaptiveSelect:(id)sender
{
	// Index 1 is to use the adaptive filter, so if selected then set useAdaptive appropriately
	useAdaptive = [sender selectedSegmentIndex] == 1;
	// and update our filter and filterLabel
	filter.adaptive = useAdaptive;
	filterLabel.text = filter.name;
	
	// Inform accessibility clients that the adaptive selection has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

#pragma  mark - MetaWear API Delegates

- (void) retrieveAccelerometerDataSuccess:(Accelerometer *)data
{
	// Update the accelerometer graph view
	if (!isPaused)
	{
		[filter addAcceleration:data];
		[unfiltered addX:data.x y:data.y z:data.z];
		[filtered addX:filter.x y:filter.y z:filter.z];
	}
}

-(void) connectionSuccessForDevice:(CBPeripheral *)device
{
    if ((self.metawearAPI.d.p != NULL) && [self.metawearAPI.d.p isConnected]) {
        [self.metawearAPI enableXYZMotionwithOptions:0];
        [self.metawearAPI enableGlobalAccelerometer];
    }
}

-(void) connectionFailed:(NSError *)error ForDevice:(CBPeripheral *)device
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Disconnected" message:@"Connection Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

-(void) disconnectionSuccessForDevice:(CBPeripheral *)device
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Disconnected" message:@"Disconnection Success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

@end
