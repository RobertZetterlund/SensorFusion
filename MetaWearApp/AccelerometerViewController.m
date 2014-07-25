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
#import "MBLAccelerometerData.h"
#import "AppDelegate.h"

@implementation AccelerometerViewController

@synthesize unfilteredGraph, filteredGraph, recordData, sendData;
@synthesize unfilteredLabel, filteredLabel, metawearAPI, filterControl, filterTypeControl;


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
        
        // Add graph for unfiltered data
        self.unfilteredLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75.0, 280.0, 20.0)];
        self.unfilteredLabel.text = @"Unfiltered Data";
        [self.view addSubview:self.unfilteredLabel];
        
        self.unfilteredGraph = [[GraphView alloc] initWithFrame:CGRectMake(0, 100.0, 320.0, 112.0)];
        [self.view addSubview:self.unfilteredGraph];
        
        // Add graph for filtered data. Dynamic based on buttons.
        self.filteredLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 225.0, 280.0, 20.0)];
        self.filteredLabel.text = @"Adaptive Highpass Filter";
        [self.view addSubview:self.filteredLabel];
        
        self.filteredGraph = [[GraphView alloc] initWithFrame:CGRectMake(0, 250.0, 320.0, 112.0)];
        [self.view addSubview:self.filteredGraph];
        
        // Control for low or high pass filter
        NSArray *itemfArray = [NSArray arrayWithObjects: @"Low Pass", @"High Pass", nil];
        self.filterControl = [[UISegmentedControl alloc] initWithItems:itemfArray];
        self.filterControl.frame = CGRectMake(20, 380.0, 280.0, 30.0);
        self.filterControl.selectedSegmentIndex = 1;
        [self.filterControl addTarget:self action:@selector(filterSelect:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.filterControl];
        
        // Control for standard or adaptive filter
        NSArray *itemsArray = [NSArray arrayWithObjects: @"Standard", @"Adaptive", nil];
        self.filterTypeControl = [[UISegmentedControl alloc] initWithItems:itemsArray];
        self.filterTypeControl.frame = CGRectMake(20, 420.0, 280.0, 30.0);
        self.filterTypeControl.selectedSegmentIndex = 1;
        [self.filterTypeControl addTarget:self action:@selector(adaptiveSelect:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.filterTypeControl];
        
        self.recordData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.recordData.frame = CGRectMake(20, 475.0, 140, 30.0);
        [self.recordData setTitle:kLocalizedStart forState:UIControlStateNormal];
        self.recordData.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.recordData addTarget:self action:@selector(startOrStopRecording:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.recordData];
        
        self.sendData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.sendData.frame = CGRectMake(160, 475.0, 140, 30.0);
        [self.sendData setTitle:@"Send Data" forState:UIControlStateNormal];
        self.sendData.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.sendData addTarget:self action:@selector(sendDataPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.sendData];
    }
    return self;
}

- (void)startOrStopRecording:(id)sender
{
	if (isRecording)
	{
		// If we're currently recording, then stop recording and set the title to "Start Recording"
        [self.recordData setTitle:kLocalizedStart forState:UIControlStateNormal];
        isRecording = NO;
        accDataString = [self processAccData];
        [self saveDatatoDisk:accDataString];
	}
	else
	{
		// If we are not recording, set the title to "Stop Recording" then start recording
        [self.recordData setTitle:kLocalizedStop forState:UIControlStateNormal];
        accDataArray = [[NSMutableArray alloc] initWithCapacity:1000];
        dataStartTime = [NSDate date];
        isRecording = YES;
	}
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)sendDataPressed:(id)sender
{
    NSString *filePath = [self saveDatatoDisk:accDataString];
    [self mailMe:filePath];
}

- (NSString *)saveDatatoDisk:(NSString *)dataString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    // Some filesystems hate colons
    NSString *dateString = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    // I hate spaces in dates
    dateString = [dateString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // OS hates forward slashes
    dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userAcceleration_%@.txt", dateString, nil]];
    [dataString writeToFile:fullPath
                              atomically:NO
                                encoding:NSStringEncodingConversionAllowLossy
                                   error:nil];
    
    return fullPath;
}

- (void)mailMe:(NSString *)filePath
{
    // Get current Time/Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    // Some filesystems hate colons
    NSString *dateString = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    // I hate spaces in dates
    dateString = [dateString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // OS hates forward slashes
    dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    // recipient address
    NSString *email = @"your@email.com";
    NSMutableArray *toRecipient = [[NSMutableArray alloc]initWithObjects:nil];
    [toRecipient addObject:email];
    MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    
    // attachment
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *name = [NSString stringWithFormat:@"AccData_%@.txt", dateString, nil];
    [emailController addAttachmentData:data mimeType:@"text/plain" fileName:name];
    
    // subject
    NSString *subject = [NSString stringWithFormat:@"Accelerometer Data %@.txt", dateString, nil];
    [emailController setSubject:subject];
    
    // message
    NSString *adaptiveString;
    if(useAdaptive)
        adaptiveString = @"adaptive";
    else
        adaptiveString = @"standard";
    
    NSString *messageBody = [NSString stringWithFormat:@"The data was recorded with a %@ %@ filter on %@.", filterType, adaptiveString, dateString,nil];
    [emailController setMessageBody:messageBody isHTML:NO];
    
    
    [emailController setToRecipients:toRecipient];
    [self presentViewController:emailController animated:YES completion:NULL];
    
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog (@"mail finished"); // NEVER REACHES THIS POINT.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	isRecording = NO;
	useAdaptive = YES;
    
	[self changeFilter:[HighpassFilter class]];
	filterType = @"high pass";
    
	[unfilteredGraph setIsAccessibilityElement:YES];
	[unfilteredGraph setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];
    
	[filteredGraph setIsAccessibilityElement:YES];
	[filteredGraph setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
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
		filteredLabel.text = filter.name;
	}
}

- (void)filterSelect:(id)sender
{
	if ([sender selectedSegmentIndex] == 0)
	{
		// Index 0 of the segment selects the lowpass filter
		[self changeFilter:[LowpassFilter class]];
        filterType = @"low pass"; // This is only used for logging purposes later.
	}
	else
	{
		// Index 1 of the segment selects the highpass filter
		[self changeFilter:[HighpassFilter class]];
        filterType = @"high pass"; // This is only used for logging purposes later.
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
	filteredLabel.text = filter.name;
	
	// Inform accessibility clients that the adaptive selection has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (NSString *)processAccData
{
    NSMutableString *AccelerometerString = [[NSMutableString alloc] init];
    for (MBLAccelerometerData *dataElement in accDataArray)
    {
        @autoreleasepool {
            [AccelerometerString appendFormat:@"%f,%f,%f,%f\n", dataElement.accDataInterval,
             dataElement.x,
             dataElement.y,
             dataElement.z];
        }
    }
    return AccelerometerString;
}
#pragma  mark - MetaWear API Delegates

- (void) retrieveAccelerometerDataSuccess:(Accelerometer *)data
{
	// Update the accelerometer graph view
	if (isRecording)
	{
        // Send both unfiltered and filtered data to graphs
		[filter addAcceleration:data];
		[unfilteredGraph addX:data.x y:data.y z:data.z];
		[filteredGraph addX:filter.x y:filter.y z:filter.z];
        
        // Add filtered data to data array for saving
        MBLAccelerometerData *accData = [[MBLAccelerometerData alloc] init];
        accData.x = filter.x;
        accData.y = filter.y;
        accData.z = filter.z;
        accData.accDataInterval = [dataStartTime timeIntervalSinceNow];
        [accDataArray addObject:accData];
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

-(void) disconnectionFailed:(NSError *)error ForDevice:(CBPeripheral *)device
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Disconnection Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

@end
