//
//  StatusViewController.m
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

#import "StatusViewController.h"
#import "AppDelegate.h"

@implementation StatusViewController

@synthesize metawearAPI, switchValue, tempValue, battValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Status";
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"Status";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        //Switch state
        UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100.0, 280.0, 20.0)];
        switchLabel.text = @"Switch State:";
        [self.view addSubview:switchLabel];
        
        self.switchValue = [[UILabel alloc] initWithFrame:CGRectMake(200, 100.0, 280.0, 20.0)];
        self.switchValue.text = @"0";
        [self.view addSubview:self.switchValue];
        
        //Temperature
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120.0, 280.0, 20.0)];
        tempLabel.text = @"Temperature:";
        [self.view addSubview:tempLabel];
        
        self.tempValue = [[UILabel alloc] initWithFrame:CGRectMake(200, 120.0, 280.0, 20.0)];
        self.tempValue.text = @"";
        [self.view addSubview:self.tempValue];
        
        //Battery
        UILabel *battLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 140.0, 280.0, 20.0)];
        battLabel.text = @"Battery Life:";
        [self.view addSubview:battLabel];
        
        self.battValue = [[UILabel alloc] initWithFrame:CGRectMake(200, 140.0, 280.0, 20.0)];
        self.battValue.text = @"";
        [self.view addSubview:self.battValue];
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
    self.metawearAPI = [MetaWearAPI alloc];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.metawearAPI = appDelegate.metawearAPI;
    
    self.metawearAPI.delegate = self;[self.metawearAPI getSwitchStatewithOptions:1];
    [self.metawearAPI enableTemperatureReadwithOptions:0];
    [self.metawearAPI readBatteryLife];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ((self.metawearAPI.d.p != NULL) && [self.metawearAPI.d.p isConnected]) {
        [self.metawearAPI getSwitchStatewithOptions:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - MetaWear API Delegates

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

-(void) retrieveSwitchValueSuccess: (Switch *)data
{
    [self.switchValue setText:[NSString stringWithFormat:@"%d",data.state]];
}

- (void) retrieveTemperatureSuccess: (Temperature *)data
{
    [self.tempValue setText:[NSString stringWithFormat:@"%f C",data.temperature]];
}

- (void) retrieveBatteryInfoSuccess: (Battery *)data
{
    [self.battValue setText:[NSString stringWithFormat:@"%d %%",data.batteryLife]];
}

@end
