//
//  FinderViewController.m
//  MetaWearAPI
//
//  Created by Laura Kassovic on 6/3/14.
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

#import "FinderViewController.h"
#import "AppDelegate.h"

@implementation FinderViewController

@synthesize metawearAPI, tmr;
@synthesize range1, range2, range3, range4, rangeView1, rangeView2, rangeView3, rangeView4, whiteView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Finder";
        
        self.metawearAPI = [[MetaWearAPI alloc] init];
        self.metawearAPI.delegate = self;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"Finder";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        self.range1 = [UIImage imageNamed:@"close1_range.png"];
        self.range2 = [UIImage imageNamed:@"close2_range.png"];
        self.range3 = [UIImage imageNamed:@"close3_range.png"];
        self.range4 = [UIImage imageNamed:@"close4_range.png"];
        
        self.rangeView1 = [[UIImageView alloc] initWithImage:self.range1];
        self.rangeView2 = [[UIImageView alloc] initWithImage:self.range2];
        self.rangeView3 = [[UIImageView alloc] initWithImage:self.range3];
        self.rangeView4 = [[UIImageView alloc] initWithImage:self.range4];
        self.rangeView1.frame = CGRectMake(self.view.frame.size.width/2-102.5, 150, 205.0, 150.0);
        self.rangeView2.frame = CGRectMake(self.view.frame.size.width/2-102.5, 150, 205.0, 150.0);
        self.rangeView3.frame = CGRectMake(self.view.frame.size.width/2-102.5, 150, 205.0, 150.0);
        self.rangeView4.frame = CGRectMake(self.view.frame.size.width/2-102.5, 150, 205.0, 150.0);
        
        UIImage *range = [UIImage imageNamed:@"close_range.png"];
        UIView *ranger = [[UIImageView alloc] initWithImage:range];
        ranger.frame = CGRectMake(self.view.frame.size.width/2-102.5, 150, 205.0, 150.0);
        [self.view addSubview:ranger];
        
        self.reminder = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-150, 300, 300.0, 80.0)];
        self.reminder.numberOfLines = 1;
        self.reminder.text = @"";
        self.reminder.textAlignment =  NSTextAlignmentCenter;
        self.reminder.textColor = [UIColor colorWithRed:237.0/255.0 green:57.0/255.0 blue:36.0/255.0 alpha:1.0];
        self.reminder.backgroundColor = [UIColor clearColor];
        self.reminder.font = [UIFont systemFontOfSize:18.0];
        [self.view addSubview:self.reminder];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.tmr invalidate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	// Do any additional setup after loading the view.
    self.metawearAPI = [[MetaWearAPI alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.metawearAPI = appDelegate.metawearAPI;
    self.metawearAPI.delegate = self;
    
    if ((self.metawearAPI.d.p != NULL) && [self.metawearAPI.d.p isConnected]) {
        [self.reminder setText:@"Searching for MetaWear"];
        [self.metawearAPI getRSSI];
        self.tmr = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(grabRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.tmr forMode:NSDefaultRunLoopMode];
    } else {
        [self.reminder setText:@"MetaWear is disconnected"];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) grabRSSI
{
    [self.metawearAPI getRSSI];
}

#pragma  mark - MetaWear API Delegates

- (void)RSSIReadSuccess:(NSNumber *)rssi
{
    //1m distance read RSSI -40dB then 2m gives -46dB, 4m gives -52dB, 8m gives -58dB, 16m gives -64dB.
    int distance = abs([rssi intValue]);
    NSLog(@"%d",distance);
    
    if([[self rangeView1] isDescendantOfView:[self view]]) {
        [self.rangeView1 removeFromSuperview];
    }
    if([[self rangeView2] isDescendantOfView:[self view]]) {
        [self.rangeView2 removeFromSuperview];
    }
    if([[self rangeView3] isDescendantOfView:[self view]]) {
        [self.rangeView3 removeFromSuperview];
    }
    if([[self rangeView4] isDescendantOfView:[self view]]) {
        [self.rangeView4 removeFromSuperview];
    }
    
    if (distance < 60) {
        [self.view addSubview:[self rangeView4]];
    }
    if (distance < 70) {
        [self.view addSubview:[self rangeView3]];
    }
    if (distance < 80) {
        [self.view addSubview:[self rangeView2]];
    }
    if (distance < 90) {
        [self.view addSubview:[self rangeView1]];
    }
}

-(void) connectionFailed:(NSError *)error ForDevice:(CBPeripheral *)device
{
    [self.tmr invalidate];
    
    self.reminder.text = @"";
    
    if([[self rangeView1] isDescendantOfView:[self view]]) {
        [self.rangeView1 removeFromSuperview];
    }
    if([[self rangeView2] isDescendantOfView:[self view]]) {
        [self.rangeView2 removeFromSuperview];
    }
    if([[self rangeView3] isDescendantOfView:[self view]]) {
        [self.rangeView3 removeFromSuperview];
    }
    if([[self rangeView4] isDescendantOfView:[self view]]) {
        [self.rangeView4 removeFromSuperview];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Disconnected" message:@"Connection Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

-(void) disconnectionSuccessForDevice:(CBPeripheral *)device
{
    [self.tmr invalidate];
    
    self.reminder.text = @"";
    
    if([[self rangeView1] isDescendantOfView:[self view]]) {
        [self.rangeView1 removeFromSuperview];
    }
    if([[self rangeView2] isDescendantOfView:[self view]]) {
        [self.rangeView2 removeFromSuperview];
    }
    if([[self rangeView3] isDescendantOfView:[self view]]) {
        [self.rangeView3 removeFromSuperview];
    }
    if([[self rangeView4] isDescendantOfView:[self view]]) {
        [self.rangeView4 removeFromSuperview];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Disconnected" message:@"Disconnection Success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

-(void) connectionSuccessForDevice:(CBPeripheral *)device
{
    [self.tmr invalidate];
    
    self.reminder.text = @"";

    if ((self.metawearAPI.d.p != NULL) && [self.metawearAPI.d.p isConnected]) {
        [self.reminder setText:@"Searching for MetaWear"];
        [self.metawearAPI getRSSI];
        self.tmr = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(grabRSSI) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.tmr forMode:NSDefaultRunLoopMode];
    }
}

@end
