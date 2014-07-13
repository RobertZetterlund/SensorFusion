//
//  LedViewController.m
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

#import "LedViewController.h"
#import "RSBrightnessSlider.h"
#import "RSOpacitySlider.h"
#import "AppDelegate.h"

@implementation LedViewController

@synthesize metawearAPI, colorR, colorB, colorG;
@synthesize onButton, offButton, pulseButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Led";
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"Led";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, self.view.frame.size.width-120, 20)];
        titleText.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleText];
        
        UILabel *colorText = [[UILabel alloc] initWithFrame:CGRectMake(40, 350, 50, 30)];
        colorText.text = @"Color";
        [self.view addSubview:colorText];
        
        self.view.backgroundColor = [UIColor whiteColor];
        self.onButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.onButton addTarget:self
                          action:@selector(turnOn)
                forControlEvents:UIControlEventTouchUpInside];
        [self.onButton setTitle:@"On" forState:UIControlStateNormal];
        self.onButton.frame = CGRectMake(20.0, 400.0, 60.0, 40.0);
        [self.view addSubview:self.onButton];
        
        self.offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.offButton addTarget:self
                           action:@selector(turnOff)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.offButton setTitle:@"Off" forState:UIControlStateNormal];
        self.offButton.frame = CGRectMake(80.0, 400.0, 60.0, 40.0);
        [self.view addSubview:self.offButton];
        
        self.pulseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.pulseButton addTarget:self
                             action:@selector(turnPulse)
                   forControlEvents:UIControlEventTouchUpInside];
        [self.pulseButton setTitle:@"Pulse" forState:UIControlStateNormal];
        self.pulseButton.frame = CGRectMake(140.0, 400.0, 60.0, 40.0);
        [self.view addSubview:self.pulseButton];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // View that displays color picker (needs to be square)
    _colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(20.0, 80.0, 280.0, 280.0)];
    
    // Set the selection color - useful to present when the user had picked a color previously
    [_colorPicker setSelectionColor:RSRandomColorOpaque(YES)];
    
    // Set the delegate to receive events
    [_colorPicker setDelegate:self];
    
    [self.view addSubview:_colorPicker];
    
    // View that shows selected color
    UILabel *colorText = [[UILabel alloc] initWithFrame:CGRectMake(160, 20, 50, 30)];
    colorText.text = @"Color";
    _colorPatch = [[UIView alloc] initWithFrame:CGRectMake(160, 400.0, 150, 30.0)];
    [self.view addSubview:_colorPatch];
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

#pragma mark - RSColorPickerView delegate methods

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
    
    // Get color data
    UIColor *color = [cp selectionColor];
    
    CGFloat r, g, b, a;
    [[cp selectionColor] getRed:&r green:&g blue:&b alpha:&a];
    
    // Update important UI
    _colorPatch.backgroundColor = color;
    _brightnessSlider.value = [cp brightness];
    _opacitySlider.value = [cp opacity];
    
    // Debug
    NSString *colorDesc = [NSString stringWithFormat:@"rgba: %f, %f, %f, %f", r, g, b, a];
    NSLog(@"%@", colorDesc);
    int ir = r * 255;
    int ig = g * 255;
    int ib = b * 255;
    int ia = a * 255;
    colorDesc = [NSString stringWithFormat:@"rgba: %d, %d, %d, %d", ir, ig, ib, ia];
    NSLog(@"%@", colorDesc);
    _rgbLabel.text = colorDesc;
    
    self.colorR = r;
    self.colorG = g;
    self.colorB = b;
    
    NSLog(@"%@", NSStringFromCGPoint(cp.selection));
}

#pragma mark - User action

- (void)testResize:(id)sender {
    if (isSmallSize) {
        _colorPicker.frame = CGRectMake(20.0, 10.0, 280.0, 280.0);
        isSmallSize = NO;
    } else {
        _colorPicker.frame = CGRectMake(40.0, 10.0, 240.0, 240.0);
        isSmallSize = YES;
    }
}

- (void)testLoup:(id)sender {
    if (_colorPicker.showLoupe) {
        _colorPicker.showLoupe = NO;
    } else {
        _colorPicker.showLoupe = YES;
    }
}

- (void)circleSwitchAction:(UISwitch *)s {
    _colorPicker.cropToCircle = s.isOn;
}

#pragma  mark - MetaWear API Delegates

- (void)turnOn
{
    [self.metawearAPI setLEDModewithColorChannel:0x00 onIntensity:15 offIntensity:1 riseTime:1000 fallTime:1000 onTime:1000 period:4000 offset:0 repeatCount:3];
    [self.metawearAPI toggleOnLEDwithOptions:1];
}

- (void)turnOff
{
    [self.metawearAPI toggleOffLEDwithOptions:1];
}

- (void)turnPulse
{
    [self.metawearAPI setLEDModewithColorChannel:0x01 onIntensity:15 offIntensity:1 riseTime:1000 fallTime:1000 onTime:1000 period:4000 offset:0 repeatCount:3];
    [self.metawearAPI toggleOnLEDwithOptions:1];
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
