//
//  DeviceDetailViewController.m
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 7/30/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "MBProgressHUD.h"
#import "APLGraphView.h"

@interface DeviceDetailViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *connectionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *tempratureLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerScale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sampleFrequency;
@property (weak, nonatomic) IBOutlet UISwitch *highPassFilterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *lowNoiseSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activePowerScheme;
@property (weak, nonatomic) IBOutlet UISwitch *autoSleepSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepSampleFrequency;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepPowerScheme;

@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerGraph;

@property (weak, nonatomic) IBOutlet UILabel *mechanicalSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLevelLabel;
@property (weak, nonatomic) IBOutlet UITextField *hapticPulseWidth;
@property (weak, nonatomic) IBOutlet UITextField *hapticDutyCycle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gpioPinSelector;
@property (weak, nonatomic) IBOutlet UILabel *gpioPinDigitalValue;
@property (weak, nonatomic) IBOutlet UILabel *gpioPinAnalogValue;

@property (weak, nonatomic) IBOutlet UIButton *startAccelerometer;
@property (weak, nonatomic) IBOutlet UIButton *stopAccelerometer;

@property (weak, nonatomic) IBOutlet UILabel *mfgNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *hwRevLabel;
@property (weak, nonatomic) IBOutlet UILabel *fwRevLabel;

@property (weak, nonatomic) IBOutlet UILabel *firmwareUpdateLabel;

@property (strong, nonatomic) UIView *grayScreen;

@property (strong, nonatomic) NSString *accDataString;
@property (strong, nonatomic) NSMutableArray *accDataArray;

@end

@implementation DeviceDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.grayScreen = [[UIView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120)];
    self.grayScreen.backgroundColor = [UIColor grayColor];
    self.grayScreen.alpha = 0.4;
    [self.view addSubview:self.grayScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self connectDevice:YES];
    
    [self.stopAccelerometer setEnabled:FALSE];
}

- (void)setConnected:(BOOL)on
{
    [self.connectionSwitch setOn:on animated:YES];
    [self.grayScreen setHidden:on];
}

- (void)connectDevice:(BOOL)on
{
    if (on) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Connecting...";
        [[MBLMetaWearManager sharedManager] connectMetaWear:self.device withHandler:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self setConnected:(error == nil)];
                hud.mode = MBProgressHUDModeText;
                if (error) {
                    hud.labelText = error.localizedDescription;
                    [hud hide:YES afterDelay:2];
                } else {
                    hud.labelText = @"Connected!";
                    [hud hide:YES afterDelay:0.5];
                }
            }];
        }];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Disconnecting...";
        [[MBLMetaWearManager sharedManager] cancelMetaWearConnection:self.device withHandler:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self setConnected:NO];
                hud.mode = MBProgressHUDModeText;
                if (error) {
                    hud.labelText = error.localizedDescription;
                    [hud hide:YES afterDelay:2];
                } else {
                    hud.labelText = @"Disconnected!";
                    [hud hide:YES afterDelay:0.5];
                }
            }];
        }];
    }
}

- (IBAction)connectionSwitchPressed:(id)sender
{
    [self connectDevice:self.connectionSwitch.on];
}

- (IBAction)readTempraturePressed:(id)sender
{
    [self.device.temperature readTemperatureWithHandler:^(NSDecimalNumber *temp, NSError *error) {
        self.tempratureLabel.text = [temp stringValue];
    }];
}

- (IBAction)turnOnGreenLEDPressed:(id)sender
{
    [self.device.led setLEDColor:[UIColor greenColor] withIntensity:0.25];
}
- (IBAction)flashGreenLEDPressed:(id)sender
{
    [self.device.led flashLEDColor:[UIColor greenColor] withIntensity:0.25];
}

- (IBAction)turnOnRedLEDPressed:(id)sender
{
    [self.device.led setLEDColor:[UIColor redColor] withIntensity:0.25];
}
- (IBAction)flashRedLEDPressed:(id)sender
{
    [self.device.led flashLEDColor:[UIColor redColor] withIntensity:0.25];
}

- (IBAction)turnOnBlueLEDPressed:(id)sender
{
    [self.device.led setLEDColor:[UIColor blueColor] withIntensity:0.25];
}
- (IBAction)flashBlueLEDPressed:(id)sender
{
    [self.device.led flashLEDColor:[UIColor blueColor] withIntensity:0.25];
}

- (IBAction)turnOffLEDPressed:(id)sender
{
    [self.device.led setLEDOn:NO withOptions:1];
}

- (IBAction)readSwitchPressed:(id)sender
{
    [self.device.mechanicalSwitch readSwitchStateWithHandler:^(BOOL isPressed, NSError *error) {
        self.mechanicalSwitchLabel.text = isPressed ? @"Down" : @"Up";
    }];
}

- (IBAction)startSwitchNotifyPressed:(id)sender
{
    [self.device.mechanicalSwitch startSwitchUpdatesWithHandler:^(BOOL isPressed, NSError *error) {
        self.mechanicalSwitchLabel.text = isPressed ? @"Down" : @"Up";
    }];
}

- (IBAction)StopSwitchNotifyPressed:(id)sender
{
    [self.device.mechanicalSwitch stopSwitchUpdates];
}

- (IBAction)readBatteryPressed:(id)sender
{
    [self.device readBatteryLifeWithHandler:^(NSNumber *number, NSError *error) {
        self.batteryLevelLabel.text = [number stringValue];
    }];
}

- (IBAction)readRSSIPressed:(id)sender
{
    [self.device readRSSIWithHandler:^(NSNumber *number, NSError *error) {
        self.rssiLevelLabel.text = [number stringValue];
    }];
}

- (IBAction)readDeviceInfoPressed:(id)sender
{
    [self.device readDeviceInfoWithHandler:^(MBLDeviceInfo *deviceInfo, NSError *error) {
        self.mfgNameLabel.text = deviceInfo.manufacturerName;
        self.serialNumLabel.text = deviceInfo.serialNumber;
        self.hwRevLabel.text = deviceInfo.hardwareRevision;
        self.fwRevLabel.text = deviceInfo.firmwareRevision;
    }];
}

- (IBAction)resetDevicePressed:(id)sender
{
    // Resetting causes a disconnection
    [self setConnected:NO];
    [self.device resetDevice];
}

- (IBAction)checkForFirmwareUpdatesPressed:(id)sender
{
    [self.device checkForFirmwareUpdateWithHandler:^(BOOL isTrue, NSError *error) {
        self.firmwareUpdateLabel.text = isTrue ? @"TODO" : @"TODO";
    }];
}

- (IBAction)updateFirmware:(id)sender
{
    // Pause the screen while update is going on
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Updating...";

    // Updating firmware causes a disconnection
    [self setConnected:NO];
    
    [self.device updateFirmwareWithHandler:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error) {
                hud.labelText = error.localizedDescription;
                NSLog(@"Firmware update error: %@", error.localizedDescription);
            } else {
                hud.labelText = @"Success!";
            }
            [hud hide:YES afterDelay:2.5];
        }];
    } progressHandler:^(float number, NSError *error) {
        hud.progress = number;
    }];
}

- (IBAction)startHapticDriverPressed:(id)sender
{
    uint8_t dcycle = [self.hapticDutyCycle.text intValue];
    uint16_t pwidth = [self.hapticPulseWidth.text intValue];
    [self.device.hapticBuzzer startHapticWithDutyCycle:dcycle pulseWidth:pwidth completion:^{
        [self.device.hapticBuzzer startHapticWithDutyCycle:dcycle pulseWidth:pwidth completion:nil];
    }];
}

- (IBAction)startiBeaconPressed:(id)sender
{
    [self.device.iBeacon setBeaconOn:YES];
}

- (IBAction)stopiBeaconPressed:(id)sender
{
    [self.device.iBeacon setBeaconOn:NO];
}

- (IBAction)setPullUpPressed:(id)sender
{
    [self.device.gpio configurePin:self.gpioPinSelector.selectedSegmentIndex withOptions:0];
}
- (IBAction)setPullDownPressed:(id)sender
{
    [self.device.gpio configurePin:self.gpioPinSelector.selectedSegmentIndex withOptions:1];
}
- (IBAction)setNoPullPressed:(id)sender
{
    [self.device.gpio configurePin:self.gpioPinSelector.selectedSegmentIndex withOptions:2];
}
- (IBAction)setPinPressed:(id)sender
{
    [self.device.gpio setPin:self.gpioPinSelector.selectedSegmentIndex toDigitalValue:YES];
}
- (IBAction)clearPinPressed:(id)sender
{
    [self.device.gpio setPin:self.gpioPinSelector.selectedSegmentIndex toDigitalValue:NO];
}
- (IBAction)readDigitalPressed:(id)sender
{
    [self.device.gpio readDigitalPin:self.gpioPinSelector.selectedSegmentIndex withHander:^(BOOL isTrue, NSError *error) {
        self.gpioPinDigitalValue.text = isTrue ? @"1" : @"0";
    }];
}
- (IBAction)readAnalogPressed:(id)sender
{
    [self.device.gpio readAnalogPin:self.gpioPinSelector.selectedSegmentIndex usingOptions:0 withHandler:^(NSDecimalNumber *number, NSError *error) {
        self.gpioPinAnalogValue.text = [number stringValue];
    }];
}

- (IBAction)startAccelerationPressed:(id)sender
{
    if (self.accelerometerScale.selectedSegmentIndex == 0) {
        self.accelerometerGraph.fullScale = 2;
    } else if (self.accelerometerScale.selectedSegmentIndex == 1) {
        self.accelerometerGraph.fullScale = 4;
    } else {
        self.accelerometerGraph.fullScale = 8;
    }
    
    self.device.accelerometer.fullScaleRange = (int)self.accelerometerScale.selectedSegmentIndex;
    self.device.accelerometer.sampleFrequency = (int)self.sampleFrequency.selectedSegmentIndex;
    self.device.accelerometer.highPassFilter = self.highPassFilterSwitch.on;
    self.device.accelerometer.lowNoise = self.highPassFilterSwitch.on;
    self.device.accelerometer.activePowerScheme = (int)self.activePowerScheme.selectedSegmentIndex;
    self.device.accelerometer.autoSleep = self.autoSleepSwitch.on;
    self.device.accelerometer.sleepSampleFrequency = (int)self.sleepSampleFrequency.selectedSegmentIndex;
    self.device.accelerometer.activePowerScheme = (int)self.activePowerScheme.selectedSegmentIndex;
   
    [self.startAccelerometer setEnabled:FALSE];
    [self.stopAccelerometer setEnabled:TRUE];
    
    // These variables are used for data recording
    self.accDataArray = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [self.device.accelerometer startAccelerometerUpdatesWithHandler:^(MBLAccelerometerData *acceleration, NSError *error) {
        [self.accelerometerGraph addX:acceleration.x y:acceleration.y z:acceleration.z];
        // Add filtered data to data array for saving
        [self.accDataArray addObject:acceleration];
    }];
}

- (IBAction)stopAccelerationPressed:(id)sender
{
    [self.device.accelerometer stopAccelerometerUpdates];
    
    [self.startAccelerometer setEnabled:TRUE];
    [self.stopAccelerometer setEnabled:FALSE];
    
    self.accDataString = [self processAccData];
}

- (NSString *)processAccData
{
    NSMutableString *AccelerometerString = [[NSMutableString alloc] init];
    for (MBLAccelerometerData *dataElement in self.accDataArray)
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

- (IBAction)sendDataPressed:(id)sender
{
    NSString *filePath = [self saveDatatoDisk:self.accDataString];
    [self mailMe:filePath];
}

- (void)mailMe:(NSString *)filePath
{
    if (![MFMailComposeViewController canSendMail]) {
        [[[UIAlertView alloc] initWithTitle:@"Mail Error" message:@"This device does not have an email account setup" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }

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
    
    
    NSString *messageBody = [NSString stringWithFormat:@"The data was recorded on %@.", dateString,nil];
    [emailController setMessageBody:messageBody isHTML:NO];
    
    
    [emailController setToRecipients:toRecipient];
    [self presentViewController:emailController animated:YES completion:NULL];
    
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog (@"mail finished"); // NEVER REACHES THIS POINT.
}

@end
