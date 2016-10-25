/**
 * DeviceDetailViewController.m
 * MetaWearApiTest
 *
 * Created by Stephen Schiffli on 7/30/14.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

#import "DeviceDetailViewController.h"
#import "MBProgressHUD.h"
#import "APLGraphView.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface DeviceDetailViewController () <DFUPeripheralSelector, LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *connectionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *connectionStateLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *setNameButton;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *allCells;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *infoAndStateCells;
@property (weak, nonatomic) IBOutlet UILabel *mfgNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *hwRevLabel;
@property (weak, nonatomic) IBOutlet UILabel *fwRevLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLevelLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *txPowerSelector;
@property (weak, nonatomic) IBOutlet UILabel *firmwareUpdateLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *mechanicalSwitchCell;
@property (weak, nonatomic) IBOutlet UILabel *mechanicalSwitchLabel;
@property (weak, nonatomic) IBOutlet UIButton *startSwitch;
@property (weak, nonatomic) IBOutlet UIButton *stopSwitch;

@property (weak, nonatomic) IBOutlet UITableViewCell *ledCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *tempCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tempChannelSelector;
@property (weak, nonatomic) IBOutlet UILabel *channelTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempratureLabel;
@property (weak, nonatomic) IBOutlet UILabel *readPinLabel;
@property (weak, nonatomic) IBOutlet UITextField *readPinTextField;
@property (weak, nonatomic) IBOutlet UILabel *enablePinLabel;
@property (weak, nonatomic) IBOutlet UITextField *enablePinTextField;

@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerMMA8452QCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerScale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sampleFrequency;
@property (weak, nonatomic) IBOutlet UISwitch *highPassFilterSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hpfCutoffFreq;
@property (weak, nonatomic) IBOutlet UISwitch *lowNoiseSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activePowerScheme;
@property (weak, nonatomic) IBOutlet UISwitch *autoSleepSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepSampleFrequency;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sleepPowerScheme;
@property (weak, nonatomic) IBOutlet UIButton *startAccelerometer;
@property (weak, nonatomic) IBOutlet UIButton *stopAccelerometer;
@property (weak, nonatomic) IBOutlet UIButton *startLog;
@property (weak, nonatomic) IBOutlet UIButton *stopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerGraph;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tapDetectionAxis;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tapDetectionType;
@property (weak, nonatomic) IBOutlet UIButton *startTap;
@property (weak, nonatomic) IBOutlet UIButton *stopTap;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (nonatomic) int tapCount;
@property (weak, nonatomic) IBOutlet UIButton *startShake;
@property (weak, nonatomic) IBOutlet UIButton *stopShake;
@property (weak, nonatomic) IBOutlet UILabel *shakeLabel;
@property (nonatomic) int shakeCount;
@property (weak, nonatomic) IBOutlet UIButton *startOrientation;
@property (weak, nonatomic) IBOutlet UIButton *stopOrientation;
@property (weak, nonatomic) IBOutlet UILabel *orientationLabel;
@property (strong, nonatomic) NSArray *accelerometerDataArray;

@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerBMI160Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMI160Scale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMI160Frequency;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartStream;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopStream;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartLog;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerBMI160Graph;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMI160TapType;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartTap;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopTap;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160TapLabel;
@property (nonatomic) int accelerometerBMI160TapCount;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartFlat;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopFlat;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160FlatLabel;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartOrient;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopOrient;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160OrientLabel;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StartStep;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMI160StopStep;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMI160StepLabel;
@property (nonatomic) int accelerometerBMI160StepCount;
@property (strong, nonatomic) NSArray *accelerometerBMI160Data;

@property (weak, nonatomic) IBOutlet UITableViewCell *accelerometerBMA255Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMA255Scale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMA255Frequency;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StartStream;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StopStream;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StartLog;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *accelerometerBMA255Graph;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accelerometerBMA255TapType;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StartTap;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StopTap;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMA255TapLabel;
@property (nonatomic) int accelerometerBMA255TapCount;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StartFlat;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StopFlat;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMA255FlatLabel;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StartOrient;
@property (weak, nonatomic) IBOutlet UIButton *accelerometerBMA255StopOrient;
@property (weak, nonatomic) IBOutlet UILabel *accelerometerBMA255OrientLabel;
@property (strong, nonatomic) NSArray *accelerometerBMA255Data;

@property (weak, nonatomic) IBOutlet UITableViewCell *gyroBMI160Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gyroBMI160Scale;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gyroBMI160Frequency;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StartStream;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StopStream;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StartLog;
@property (weak, nonatomic) IBOutlet UIButton *gyroBMI160StopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *gyroBMI160Graph;
@property (strong, nonatomic) NSArray *gyroBMI160Data;

@property (weak, nonatomic) IBOutlet UITableViewCell *magnetometerBMM150Cell;
@property (weak, nonatomic) IBOutlet UIButton *magnetometerBMM150StartStream;
@property (weak, nonatomic) IBOutlet UIButton *magnetometerBMM150StopStream;
@property (weak, nonatomic) IBOutlet UIButton *magnetometerBMM150StartLog;
@property (weak, nonatomic) IBOutlet UIButton *magnetometerBMM150StopLog;
@property (weak, nonatomic) IBOutlet APLGraphView *magnetometerBMM150Graph;
@property (strong, nonatomic) NSArray *magnetometerBMM150Data;

@property (weak, nonatomic) IBOutlet UITableViewCell *gpioCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gpioPinSelector;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gpioPinChangeType;
@property (weak, nonatomic) IBOutlet UIButton *gpioStartPinChange;
@property (weak, nonatomic) IBOutlet UIButton *gpioStopPinChange;
@property (weak, nonatomic) IBOutlet UILabel *gpioPinChangeLabel;
@property (nonatomic) int gpioPinChangeCount;
@property (weak, nonatomic) IBOutlet UILabel *gpioDigitalValue;
@property (weak, nonatomic) IBOutlet UIButton *gpioAnalogAbsoluteButton;
@property (weak, nonatomic) IBOutlet UILabel *gpioAnalogAbsoluteValue;
@property (weak, nonatomic) IBOutlet UIButton *gpioAnalogRatioButton;
@property (weak, nonatomic) IBOutlet UILabel *gpioAnalogRatioValue;

@property (weak, nonatomic) IBOutlet UITableViewCell *hapticCell;
@property (weak, nonatomic) IBOutlet UITextField *hapticPulseWidth;
@property (weak, nonatomic) IBOutlet UITextField *hapticDutyCycle;

@property (weak, nonatomic) IBOutlet UITableViewCell *iBeaconCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *barometerBMP280Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBMP280Oversampling;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBMP280Averaging;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBMP280Standby;
@property (weak, nonatomic) IBOutlet UIButton *barometerBMP280StartStream;
@property (weak, nonatomic) IBOutlet UIButton *barometerBMP280StopStream;
@property (weak, nonatomic) IBOutlet UILabel *barometerBMP280Altitude;

@property (weak, nonatomic) IBOutlet UITableViewCell *barometerBME280Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBME280Oversampling;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBME280Averaging;
@property (weak, nonatomic) IBOutlet UISegmentedControl *barometerBME280Standby;
@property (weak, nonatomic) IBOutlet UIButton *barometerBME280StartStream;
@property (weak, nonatomic) IBOutlet UIButton *barometerBME280StopStream;
@property (weak, nonatomic) IBOutlet UILabel *barometerBME280Altitude;

@property (weak, nonatomic) IBOutlet UITableViewCell *ambientLightLTR329Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ambientLightLTR329Gain;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ambientLightLTR329Integration;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ambientLightLTR329Measurement;
@property (weak, nonatomic) IBOutlet UIButton *ambientLightLTR329StartStream;
@property (weak, nonatomic) IBOutlet UIButton *ambientLightLTR329StopStream;
@property (weak, nonatomic) IBOutlet UILabel *ambientLightLTR329Illuminance;

@property (weak, nonatomic) IBOutlet UITableViewCell *proximityTSL2671Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *proximityTSL2671Drive;
@property (weak, nonatomic) IBOutlet UILabel *proximityTSL2671IntegrationLabel;
@property (weak, nonatomic) IBOutlet UISlider *proximityTSL2671IntegrationSlider;
@property (weak, nonatomic) IBOutlet UILabel *proximityTSL2671PulseLabel;
@property (weak, nonatomic) IBOutlet UIStepper *proximityTSL2671PulseStepper;
@property (weak, nonatomic) IBOutlet UIButton *proximityTSL2671StartStream;
@property (weak, nonatomic) IBOutlet UIButton *proximityTSL2671StopStream;
@property (weak, nonatomic) IBOutlet UILabel *proximityTSL2671Proximity;
@property (nonatomic) MBLEvent<MBLNumericData *> *proximityTSL2671Event;

@property (weak, nonatomic) IBOutlet UITableViewCell *photometerTCS3472Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *photometerTCS3472Gain;
@property (weak, nonatomic) IBOutlet UILabel *photometerTCS3472IntegrationLabel;
@property (weak, nonatomic) IBOutlet UISlider *photometerTCS3472IntegrationSlider;
@property (weak, nonatomic) IBOutlet UISwitch *photometerTCS3472LedFlashSwitch;
@property (weak, nonatomic) IBOutlet UIButton *photometerTCS3472StartStream;
@property (weak, nonatomic) IBOutlet UIButton *photometerTCS3472StopStream;
@property (weak, nonatomic) IBOutlet UILabel *photometerTCS3472RedColor;
@property (weak, nonatomic) IBOutlet UILabel *photometerTCS3472GreenColor;
@property (weak, nonatomic) IBOutlet UILabel *photometerTCS3472BlueColor;
@property (weak, nonatomic) IBOutlet UILabel *photometerTCS3472ClearColor;
@property (nonatomic) MBLEvent<MBLRGBData *> *photometerTCS3472Event;

@property (weak, nonatomic) IBOutlet UITableViewCell *hygrometerBME280Cell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hygrometerBME280Oversample;
@property (weak, nonatomic) IBOutlet UIButton *hygrometerBME280StartStream;
@property (weak, nonatomic) IBOutlet UIButton *hygrometerBME280StopStream;
@property (weak, nonatomic) IBOutlet UILabel *hygrometerBME280Humidity;
@property (nonatomic) MBLEvent<MBLNumericData *> *hygrometerBME280Event;

@property (weak, nonatomic) IBOutlet UITableViewCell *i2cCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *i2cSizeSelector;
@property (weak, nonatomic) IBOutlet UITextField *i2cDeviceAddress;
@property (weak, nonatomic) IBOutlet UITextField *i2cRegisterAddress;
@property (weak, nonatomic) IBOutlet UILabel *i2cReadByteLabel;
@property (weak, nonatomic) IBOutlet UITextField *i2cWriteByteField;

@property (weak, nonatomic) IBOutlet UITableViewCell *conductanceCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *conductanceGain;
@property (weak, nonatomic) IBOutlet UISegmentedControl *conductanceVoltage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *conductanceRange;
@property (weak, nonatomic) IBOutlet UIStepper *conductanceChannelStepper;
@property (weak, nonatomic) IBOutlet UILabel *conductanceChannelLabel;
@property (weak, nonatomic) IBOutlet UIButton *conductanceStartStream;
@property (weak, nonatomic) IBOutlet UIButton *conductanceStopStream;
@property (weak, nonatomic) IBOutlet UILabel *conductanceLabel;
@property (nonatomic) MBLEvent<MBLNumericData *> *conductanceEvent;

@property (weak, nonatomic) IBOutlet UITableViewCell *neopixelCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *neopixelColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *neopixelSpeed;
@property (weak, nonatomic) IBOutlet UISegmentedControl *neopixelPin;
@property (weak, nonatomic) IBOutlet UIStepper *neopixelLengthStepper;
@property (weak, nonatomic) IBOutlet UILabel *neopixelLengthLabel;
@property (weak, nonatomic) IBOutlet UIButton *neopixelSetRed;
@property (weak, nonatomic) IBOutlet UIButton *neopixelSetGreen;
@property (weak, nonatomic) IBOutlet UIButton *neopixelSetBlue;
@property (weak, nonatomic) IBOutlet UIButton *neopixelSetRainbow;
@property (weak, nonatomic) IBOutlet UIButton *neopixelRotateRight;
@property (weak, nonatomic) IBOutlet UIButton *neopixelRotateLeft;
@property (weak, nonatomic) IBOutlet UIButton *neopixelTurnOff;
@property (nonatomic) MBLNeopixelStrand *neopixelStrand;
@property (nonatomic) BFTask *neopixelStrandInitTask;

@property (nonatomic, strong) NSMutableArray *streamingEvents;
@property (nonatomic) BOOL isObserving;
@property (nonatomic) MBProgressHUD *hud;

@property (nonatomic, strong) UIDocumentInteractionController *controller;
@end

@implementation DeviceDetailViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Use this array to keep track of all streaming events, so turn them off
    // in case the user isn't so responsible
    self.streamingEvents = [NSMutableArray array];
    
    // Hide every section in the beginning
    self.hideSectionsWithHiddenRows = YES;
    [self cells:self.allCells setHidden:YES];
    [self reloadDataAnimated:NO];
    
    // Write in the 2 fields we know at time zero
    self.connectionStateLabel.text = [self nameForState];
    self.nameTextField.text = self.device.name;
    
    // Listen for state changes
    self.isObserving = YES;
    
    // Start off the connection flow
    [self connectDevice:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isObserving = NO;
    
    for (MBLEvent *event in self.streamingEvents) {
        [event stopNotificationsAsync];
    }
    [self.streamingEvents removeAllObjects];
}

- (void)setIsObserving:(BOOL)isObserving
{
    @synchronized(self) {
        if (isObserving) {
            if (_isObserving) {
                // Do nothing
            } else {
                [self.device addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            }
        } else {
            if (_isObserving) {
                [self.device removeObserver:self forKeyPath:@"state"];
            } else {
                // Do nothing
            }
        }
        _isObserving = isObserving;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.connectionStateLabel.text = [self nameForState];
        if (self.device.state == CBPeripheralStateDisconnected) {
            [self deviceDisconnected];
        }
    }];
}

- (NSString *)nameForState
{
    switch (self.device.state) {
        case MBLConnectionStateConnected:
            return self.device.programedByOtherApp ? @"Connected (LIMITED)" : @"Connected";
        case MBLConnectionStateConnecting:
            return @"Connecting";
        case MBLConnectionStateDisconnected:
            return @"Disconnected";
        case MBLConnectionStateDisconnecting:
            return @"Disconnecting";
        case MBLConnectionStateDiscovery:
            return @"Discovery";
    }
}

- (void)logCleanup:(MBLErrorHandler)handler
{
    // In order for the device to actaully erase the flash memory we can't be in a connection
    // so temporally disconnect to allow flash to erase.
    self.isObserving = NO;
    [[[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
        self.isObserving = YES;
        if (t.error) {
            return t;
        }
        return [self.device connectWithTimeoutAsync:15];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
        if (handler) {
            handler(t.error);
        }
        return nil;
    }];
}

- (void)showAlertTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
}

- (void)deviceDisconnected
{
    [self.connectionSwitch setOn:NO animated:YES];
    
    [self cells:self.allCells setHidden:YES];
    [self reloadDataAnimated:YES];
}

- (void)deviceConnected
{
    [self.connectionSwitch setOn:YES animated:YES];
    // Perform all device specific setup
 
    if (self.device.settings.macAddress) {
        [[self.device.settings.macAddress readAsync] success:^(MBLStringData * _Nonnull result) {
            NSLog(@"ID: %@ MAC: %@", self.device.identifier.UUIDString, result.value);
        }];
    } else {
        NSLog(@"ID: %@", self.device.identifier.UUIDString);
    }
    
    // We always have the info and state features
    [self cells:self.infoAndStateCells setHidden:NO];
    self.mfgNameLabel.text = self.device.deviceInfo.manufacturerName;
    self.serialNumLabel.text = self.device.deviceInfo.serialNumber;
    self.hwRevLabel.text = self.device.deviceInfo.hardwareRevision;
    self.fwRevLabel.text = self.device.deviceInfo.firmwareRevision;
    self.modelNumberLabel.text = self.device.deviceInfo.modelNumber;
    self.txPowerSelector.selectedSegmentIndex = self.device.settings.transmitPower;
    // Automaticaly send off some reads
    [self readBatteryPressed:nil];
    [self readRSSIPressed:nil];
    [self checkForFirmwareUpdatesPressed:nil];
    
    if (self.device.led) {
        [self cell:self.ledCell setHidden:NO];
    }
    
    // Only allow LED module if the device is in use by other app
    if (self.device.programedByOtherApp) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ihaveseenprogramedByOtherAppmessage"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"ihaveseenprogramedByOtherAppmessage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self showAlertTitle:@"WARNING" message:@"You have connected to a device being used by another app.  To prevent errors and data loss for the other application we are only showing a limited number of features.  If you wish to take control please press 'Reset To Factory Defaults', which will wipe the device clean."];
        }
        [self reloadDataAnimated:YES];
        return;
    }
    
    // Go through each module and enable the correct cell for the modules on this particular MetaWear
    if (self.device.mechanicalSwitch) {
        [self cell:self.mechanicalSwitchCell setHidden:NO];
    }
    
    if (self.device.temperature) {
        [self cell:self.tempCell setHidden:NO];
        // The number of channels is variable
        [self.tempChannelSelector removeAllSegments];
        for (int i = 0; i < self.device.temperature.channels.count; i++) {
            [self.tempChannelSelector insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
        }
        [self.tempChannelSelector setSelectedSegmentIndex:0];
        [self tempChannelSelectorPressed:self.tempChannelSelector];
    }
    
    if ([self.device.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
        [self cell:self.accelerometerMMA8452QCell setHidden:NO];
        if (self.device.accelerometer.dataReadyEvent.isLogging) {
            [self.startLog setEnabled:NO];
            [self.stopLog setEnabled:YES];
            [self.startAccelerometer setEnabled:NO];
            [self.stopAccelerometer setEnabled:NO];
        } else {
            [self.startLog setEnabled:YES];
            [self.stopLog setEnabled:NO];
            [self.startAccelerometer setEnabled:YES];
            [self.stopAccelerometer setEnabled:NO];
        }
    } else if ([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
        [self cell:self.accelerometerBMI160Cell setHidden:NO];
        if (self.device.accelerometer.dataReadyEvent.isLogging) {
            [self.accelerometerBMI160StartLog setEnabled:NO];
            [self.accelerometerBMI160StopLog setEnabled:YES];
            [self.accelerometerBMI160StartStream setEnabled:NO];
            [self.accelerometerBMI160StopStream setEnabled:NO];
        } else {
            [self.accelerometerBMI160StartLog setEnabled:YES];
            [self.accelerometerBMI160StopLog setEnabled:NO];
            [self.accelerometerBMI160StartStream setEnabled:YES];
            [self.accelerometerBMI160StopStream setEnabled:NO];
        }
    } else if ([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMA255 class]]) {
        [self cell:self.accelerometerBMA255Cell setHidden:NO];
        if (self.device.accelerometer.dataReadyEvent.isLogging) {
            [self.accelerometerBMA255StartLog setEnabled:NO];
            [self.accelerometerBMA255StopLog setEnabled:YES];
            [self.accelerometerBMA255StartStream setEnabled:NO];
            [self.accelerometerBMA255StopStream setEnabled:NO];
        } else {
            [self.accelerometerBMA255StartLog setEnabled:YES];
            [self.accelerometerBMA255StopLog setEnabled:NO];
            [self.accelerometerBMA255StartStream setEnabled:YES];
            [self.accelerometerBMA255StopStream setEnabled:NO];
        }
    }
    
    if ([self.device.gyro isKindOfClass:[MBLGyroBMI160 class]]) {
        [self cell:self.gyroBMI160Cell setHidden:NO];
        if (self.device.gyro.dataReadyEvent.isLogging) {
            [self.gyroBMI160StartLog setEnabled:NO];
            [self.gyroBMI160StopLog setEnabled:YES];
            [self.gyroBMI160StartStream setEnabled:NO];
            [self.gyroBMI160StopStream setEnabled:NO];
        } else {
            [self.gyroBMI160StartLog setEnabled:YES];
            [self.gyroBMI160StopLog setEnabled:NO];
            [self.gyroBMI160StartStream setEnabled:YES];
            [self.gyroBMI160StopStream setEnabled:NO];
        }
    }
    
    if ([self.device.magnetometer isKindOfClass:[MBLMagnetometerBMM150 class]]) {
        [self cell:self.magnetometerBMM150Cell setHidden:NO];
        MBLMagnetometerBMM150 *magnetometerBMM150 = (MBLMagnetometerBMM150 *)self.device.magnetometer;
        if (magnetometerBMM150.periodicMagneticField.isLogging) {
            [self.magnetometerBMM150StartLog setEnabled:NO];
            [self.magnetometerBMM150StopLog setEnabled:YES];
            [self.magnetometerBMM150StartStream setEnabled:NO];
            [self.magnetometerBMM150StopStream setEnabled:NO];
        } else {
            [self.magnetometerBMM150StartLog setEnabled:YES];
            [self.magnetometerBMM150StopLog setEnabled:NO];
            [self.magnetometerBMM150StartStream setEnabled:YES];
            [self.magnetometerBMM150StopStream setEnabled:NO];
        }
    }
    
    if (self.device.gpio.pins.count) {
        [self cell:self.gpioCell setHidden:NO];
        // The number of pins is variable
        [self.gpioPinSelector removeAllSegments];
        for (int i = 0; i < self.device.gpio.pins.count; i++) {
            [self.gpioPinSelector insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
        }
        [self.gpioPinSelector setSelectedSegmentIndex:0];
        
        
    }
    
    if (self.device.hapticBuzzer) {
        [self cell:self.hapticCell setHidden:NO];
    }
    
    if (self.device.iBeacon) {
        [self cell:self.iBeaconCell setHidden:NO];
    }
    
    if ([self.device.barometer isKindOfClass:[MBLBarometerBMP280 class]]) {
        [self cell:self.barometerBMP280Cell setHidden:NO];
    } else if ([self.device.barometer isKindOfClass:[MBLBarometerBME280 class]]) {
        [self cell:self.barometerBME280Cell setHidden:NO];
    }
    
    if ([self.device.ambientLight isKindOfClass:[MBLAmbientLightLTR329 class]]) {
        [self cell:self.ambientLightLTR329Cell setHidden:NO];
    }
    
    if ([self.device.proximity isKindOfClass:[MBLProximityTSL2671 class]]) {
        [self cell:self.proximityTSL2671Cell setHidden:NO];
    }

    if ([self.device.photometer isKindOfClass:[MBLPhotometerTCS3472 class]]) {
        [self cell:self.photometerTCS3472Cell setHidden:NO];
    }

    if ([self.device.hygrometer isKindOfClass:[MBLHygrometerBME280 class]]) {
        [self cell:self.hygrometerBME280Cell setHidden:NO];
    }
    
    if (self.device.serial) {
        [self cell:self.i2cCell setHidden:NO];
    }
    
    if (self.device.conductance) {
        self.conductanceChannelStepper.maximumValue = self.device.conductance.channels.count - 1;
        [self cell:self.conductanceCell setHidden:NO];
    }
    
    if (self.device.neopixel) {
        [self cell:self.neopixelCell setHidden:NO];
        // The number of pins is variable
        [self.neopixelPin removeAllSegments];
        for (int i = 0; i < self.device.gpio.pins.count; i++) {
            [self.neopixelPin insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
        }
        [self.neopixelPin setSelectedSegmentIndex:0];
        [self gpioPinSelectorPressed:self.gpioPinSelector];

    }
    
    // Make the magic happen!
    [self reloadDataAnimated:YES];
}

- (void)connectDevice:(BOOL)on
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    if (on) {
        hud.label.text = @"Connecting...";
        [[self.device connectWithTimeoutAsync:15] continueOnDispatchWithBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
            if ([t.error.domain isEqualToString:kMBLErrorDomain] && t.error.code == kMBLErrorOutdatedFirmware) {
                [hud hideAnimated:YES];
                self.firmwareUpdateLabel.text = @"Force Update";
                [self updateFirmware:nil];
                return nil;
            }
            
            hud.mode = MBProgressHUDModeText;
            if (t.error) {
                [self showAlertTitle:@"Error" message:t.error.localizedDescription];
                [hud hideAnimated:NO];
            } else {
                [self deviceConnected];
                
                hud.label.text = @"Connected!";
                [hud hideAnimated:YES afterDelay:0.5];
            }
            return nil;
        }];
    } else {
        hud.label.text = @"Disconnecting...";
        [[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
            [self deviceDisconnected];
            hud.mode = MBProgressHUDModeText;
            if (t.error) {
                [self showAlertTitle:@"Error" message:t.error.localizedDescription];
                [hud hideAnimated:NO];
            } else {
                hud.label.text = @"Disconnected!";
                [hud hideAnimated:YES afterDelay:0.5];
            }
            return nil;
        }];
    }
}


- (IBAction)connectionSwitchPressed:(id)sender
{
    [self connectDevice:self.connectionSwitch.on];
}

- (IBAction)setNamePressed:(id)sender
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ihaveseennamemessage"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"ihaveseennamemessage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showAlertTitle:@"Notice" message:@"Because of how iOS caches names, you have to disconnect and re-connect a few times or force close and re-launch the app before you see the new name!"];
    }
    [self.nameTextField resignFirstResponder];
    self.device.name = self.nameTextField.text;
    self.setNameButton.enabled = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // return NO to not change text
    self.setNameButton.enabled = YES;
    
    // Prevent Undo crashing bug
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    // Make sure it's no longer than 8 characters
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 8) {
        return NO;
    }
    // Make sure we only use ASCII characters
    return [string dataUsingEncoding:NSASCIIStringEncoding] != nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // called when 'return' key pressed. return NO to ignore.
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)readBatteryPressed:(id)sender
{
    [[[self.device readBatteryLifeAsync] success:^(NSNumber * _Nonnull result) {
        self.batteryLevelLabel.text = result.stringValue;
    }] failure:^(NSError * _Nonnull error) {
        if (sender) {
            [self showAlertTitle:@"Error" message:error.localizedDescription];
        }
    }];
}

- (IBAction)readRSSIPressed:(id)sender
{
    [[[self.device readRSSIAsync] success:^(NSNumber * _Nonnull result) {
        self.rssiLevelLabel.text = result.stringValue;
    }] failure:^(NSError * _Nonnull error) {
        if (sender) {
            [self showAlertTitle:@"Error" message:error.localizedDescription];
        }
    }];
}

- (IBAction)txPowerChanged:(id)sender
{
    self.device.settings.transmitPower = self.txPowerSelector.selectedSegmentIndex;
}


- (IBAction)checkForFirmwareUpdatesPressed:(id)sender
{
    [[[self.device checkForFirmwareUpdateAsync] success:^(NSNumber * _Nonnull result) {
        self.firmwareUpdateLabel.text = result.boolValue ? @"AVAILABLE!" : @"Up To Date";
    }] failure:^(NSError * _Nonnull error) {
        if (sender) {
            [self showAlertTitle:@"Error" message:error.localizedDescription];
        }
    }];
}

- (IBAction)updateFirmware:(id)sender
{
    // Pause the screen while update is going on
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    self.hud.label.text = @"Updating...";
    
    [[[self.device prepareForFirmwareUpdateAsync] success:^(MBLFirmwareUpdateInfo * _Nonnull result) {
        DFUFirmware *selectedFirmware;
        if ([result.firmwareUrl.pathExtension caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
            selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:result.firmwareUrl];
        } else {
            selectedFirmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:result.firmwareUrl urlToDatFile:nil type:DFUFirmwareTypeApplication];
        }
        
        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:result.centralManager target:result.target];
        [initiator withFirmwareFile:selectedFirmware];
        initiator.forceDfu = YES; // We also have the DIS which confuses the DFU library
        initiator.logger = self; // - to get log info
        initiator.delegate = self; // - to be informed about current state and errors
        initiator.progressDelegate = self; // - to show progress bar
        initiator.peripheralSelector = self;
        
        [initiator start];
    }] failure:^(NSError * _Nonnull error) {
        NSLog(@"Firmware update error: %@", error.localizedDescription);
        [[[UIAlertView alloc] initWithTitle:@"Update Error"
                                    message:[@"Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: " stringByAppendingString:error.localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
        [self.hud hideAnimated:YES];
    }];
}

- (IBAction)resetDevicePressed:(id)sender
{
    // Resetting causes a disconnection
    [self deviceDisconnected];
    // Preform the soft reset
    [self.device resetDevice];
}

- (IBAction)factoryDefaultsPressed:(id)sender
{
    // Resetting causes a disconnection
    [self deviceDisconnected];
    
    // In case any pairing information is on the device mark it for removal too
    [self.device.settings deleteAllBondsAsync];
    // Setting a nil configuration removes state perisited in flash memory
    [self.device setConfigurationAsync:nil];
}


- (IBAction)readSwitchPressed:(id)sender
{
    [[self.device.mechanicalSwitch.switchValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        self.mechanicalSwitchLabel.text = result.value.boolValue ? @"Down" : @"Up";
    }];
}

- (IBAction)startSwitchNotifyPressed:(id)sender
{
    [self.startSwitch setEnabled:NO];
    [self.stopSwitch setEnabled:YES];
    
    [self.streamingEvents addObject:self.device.mechanicalSwitch.switchUpdateEvent];
    [self.device.mechanicalSwitch.switchUpdateEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.mechanicalSwitchLabel.text = obj.value.boolValue ? @"Down" : @"Up";
        }
    }];
}

- (IBAction)stopSwitchNotifyPressed:(id)sender
{
    [self.startSwitch setEnabled:YES];
    [self.stopSwitch setEnabled:NO];
    
    [self.streamingEvents removeObject:self.device.mechanicalSwitch.switchUpdateEvent];
    [self.device.mechanicalSwitch.switchUpdateEvent stopNotificationsAsync];
}


- (IBAction)turnOnGreenLEDPressed:(id)sender
{
    [self.device.led setLEDColorAsync:[UIColor greenColor] withIntensity:1.0];
}
- (IBAction)flashGreenLEDPressed:(id)sender
{
    [self.device.led flashLEDColorAsync:[UIColor greenColor] withIntensity:1.0];
}

- (IBAction)turnOnRedLEDPressed:(id)sender
{
    [self.device.led setLEDColorAsync:[UIColor redColor] withIntensity:1.0];
}
- (IBAction)flashRedLEDPressed:(id)sender
{
    [self.device.led flashLEDColorAsync:[UIColor redColor] withIntensity:1.0];
}

- (IBAction)turnOnBlueLEDPressed:(id)sender
{
    [self.device.led setLEDColorAsync:[UIColor blueColor] withIntensity:1.0];
}
- (IBAction)flashBlueLEDPressed:(id)sender
{
    [self.device.led flashLEDColorAsync:[UIColor blueColor] withIntensity:1.0];
}

- (IBAction)turnOffLEDPressed:(id)sender
{
    [self.device.led setLEDOnAsync:NO withOptions:1];
}


- (IBAction)tempChannelSelectorPressed:(id)sender
{
    MBLData *selected = self.device.temperature.channels[self.tempChannelSelector.selectedSegmentIndex];
    if (selected == self.device.temperature.onDieThermistor) {
        self.channelTypeLabel.text = @"On-Die";
    } else if (selected == self.device.temperature.onboardThermistor) {
        self.channelTypeLabel.text = @"On-Board";
    } else if (selected == self.device.temperature.externalThermistor) {
        self.channelTypeLabel.text = @"External";
    } else {
        self.channelTypeLabel.text = @"Custom";
    }
    
    if ([selected isKindOfClass:[MBLExternalThermistor class]]) {
        [self.readPinLabel setHidden:NO];
        [self.readPinTextField setHidden:NO];
        [self.enablePinLabel setHidden:NO];
        [self.enablePinTextField setHidden:NO];
    } else {
        [self.readPinLabel setHidden:YES];
        [self.readPinTextField setHidden:YES];
        [self.enablePinLabel setHidden:YES];
        [self.enablePinTextField setHidden:YES];
    }
}

- (IBAction)readTempraturePressed:(id)sender
{
    MBLData<MBLNumericData *> *selected = self.device.temperature.channels[self.tempChannelSelector.selectedSegmentIndex];
    if ([selected isKindOfClass:[MBLExternalThermistor class]]) {
        ((MBLExternalThermistor *)selected).readPin = [self.readPinTextField.text intValue];
        ((MBLExternalThermistor *)selected).enablePin = [self.enablePinTextField.text intValue];
    }
    [[selected readAsync] success:^(MBLNumericData * _Nonnull result) {
        self.tempratureLabel.text = [result.value.stringValue stringByAppendingString:@"°C"];
    }];
}


- (void)updateAccelerometerSettings
{
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    if (self.accelerometerScale.selectedSegmentIndex == 0) {
        self.accelerometerGraph.fullScale = 2;
    } else if (self.accelerometerScale.selectedSegmentIndex == 1) {
        self.accelerometerGraph.fullScale = 4;
    } else {
        self.accelerometerGraph.fullScale = 8;
    }
    
    accelerometerMMA8452Q.fullScaleRange = (int)self.accelerometerScale.selectedSegmentIndex;
    accelerometerMMA8452Q.sampleFrequency = [[self.sampleFrequency titleForSegmentAtIndex:self.sampleFrequency.selectedSegmentIndex] floatValue];
    accelerometerMMA8452Q.highPassFilter = self.highPassFilterSwitch.on;
    accelerometerMMA8452Q.highPassCutoffFreq = self.hpfCutoffFreq.selectedSegmentIndex;
    accelerometerMMA8452Q.lowNoise = self.lowNoiseSwitch.on;
    accelerometerMMA8452Q.activePowerScheme = (int)self.activePowerScheme.selectedSegmentIndex;
    accelerometerMMA8452Q.autoSleep = self.autoSleepSwitch.on;
    accelerometerMMA8452Q.sleepSampleFrequency = (int)self.sleepSampleFrequency.selectedSegmentIndex;
    accelerometerMMA8452Q.sleepPowerScheme = (int)self.sleepPowerScheme.selectedSegmentIndex;
    accelerometerMMA8452Q.tapDetectionAxis = (int)self.tapDetectionAxis.selectedSegmentIndex;
    accelerometerMMA8452Q.tapType = (int)self.tapDetectionType.selectedSegmentIndex;
}

- (IBAction)startAccelerationPressed:(id)sender
{
    [self.startAccelerometer setEnabled:NO];
    [self.stopAccelerometer setEnabled:YES];
    [self.startLog setEnabled:NO];
    [self.stopLog setEnabled:NO];
    
    [self updateAccelerometerSettings];
    
    // These variables are used for data recording
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.accelerometerDataArray = array;
    
    [self.streamingEvents addObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData * _Nullable acceleration, NSError * _Nullable error) {
        if (acceleration) {
            [self.accelerometerGraph addX:acceleration.x y:acceleration.y z:acceleration.z];
            // Add data to data array for saving
            [array addObject:acceleration];
        }
    }];
}

- (IBAction)stopAccelerationPressed:(id)sender
{
    [self.startAccelerometer setEnabled:YES];
    [self.stopAccelerometer setEnabled:NO];
    [self.startLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
}

- (IBAction)startAccelerometerLog:(id)sender
{
    [self.startLog setEnabled:NO];
    [self.stopLog setEnabled:YES];
    [self.startAccelerometer setEnabled:NO];
    [self.stopAccelerometer setEnabled:NO];
    
    [self updateAccelerometerSettings];
    
    [self.device.accelerometer.dataReadyEvent startLoggingAsync];
}

- (IBAction)stopAccelerometerLog:(id)sender
{
    [self.stopLog setEnabled:NO];
    [self.startLog setEnabled:YES];
    [self.startAccelerometer setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Downloading...";
    
    [[[self.device.accelerometer.dataReadyEvent downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
        hud.progress = number;
    }] success:^(NSArray<MBLAccelerometerData *> * _Nonnull array) {
        self.accelerometerDataArray = array;
        for (MBLAccelerometerData *acceleration in array) {
            [self.accelerometerGraph addX:acceleration.x y:acceleration.y z:acceleration.z];
        }
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Clearing Log...";
        [self logCleanup:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error) {
                [self connectDevice:NO];
            }
        }];
    }] failure:^(NSError * _Nonnull error) {
        [self connectDevice:NO];
        [hud hideAnimated:YES];
    }];
}

- (IBAction)sendDataPressed:(id)sender
{
    NSMutableData *accelerometerData = [NSMutableData data];
    for (MBLAccelerometerData *dataElement in self.accelerometerDataArray) {
        @autoreleasepool {
            [accelerometerData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                            dataElement.timestamp.timeIntervalSince1970,
                                            dataElement.x,
                                            dataElement.y,
                                            dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendData:accelerometerData title:@"AccData"];
}

- (void)sendData:(NSData *)data title:(NSString *)title
{
    // Get current Time/Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_yyyy-HH_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *name = [NSString stringWithFormat:@"%@_%@.csv", title, dateString];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
    NSError *error = nil;
    if ([data writeToURL:fileURL options:NSDataWritingAtomic error:&error]) {
        // Popup the default share screen
        self.controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        if (![self.controller presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES]) {
            [self showAlertTitle:@"Error" message:@"No programs installed that could save document"];
        }
    } else {
        [self showAlertTitle:@"Error" message:error.localizedDescription];
    }
}

- (IBAction)startTapPressed:(id)sender
{
    [self.startTap setEnabled:NO];
    [self.stopTap setEnabled:YES];
    
    [self updateAccelerometerSettings];
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerMMA8452Q.tapEvent];
    [accelerometerMMA8452Q.tapEvent startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.tapLabel.text = [NSString stringWithFormat:@"Tap Count: %d", ++self.tapCount];
        }
    }];
}

- (IBAction)stopTapPressed:(id)sender
{
    [self.startTap setEnabled:YES];
    [self.stopTap setEnabled:NO];
    
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerMMA8452Q.tapEvent];
    [accelerometerMMA8452Q.tapEvent stopNotificationsAsync];
    self.tapCount = 0;
    self.tapLabel.text = @"Tap Count: 0";
}

- (IBAction)startShakePressed:(id)sender
{
    [self.startShake setEnabled:NO];
    [self.stopShake setEnabled:YES];
    
    [self updateAccelerometerSettings];
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerMMA8452Q.shakeEvent];
    [accelerometerMMA8452Q.shakeEvent startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.shakeLabel.text = [NSString stringWithFormat:@"Shakes: %d", ++self.shakeCount];
        }
    }];
}

- (IBAction)stopShakePressed:(id)sender
{
    [self.startShake setEnabled:YES];
    [self.stopShake setEnabled:NO];
    
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerMMA8452Q.shakeEvent];
    [accelerometerMMA8452Q.shakeEvent stopNotificationsAsync];
    self.shakeCount = 0;
    self.shakeLabel.text = @"Shakes: 0";
}

- (IBAction)startOrientationPressed:(id)sender
{
    [self.startOrientation setEnabled:NO];
    [self.stopOrientation setEnabled:YES];
    
    [self updateAccelerometerSettings];
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerMMA8452Q.orientationEvent];
    [accelerometerMMA8452Q.orientationEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            switch (obj.orientation) {
                case MBLAccelerometerOrientationPortrait:
                    self.orientationLabel.text = @"Portrait";
                    break;
                case MBLAccelerometerOrientationPortraitUpsideDown:
                    self.orientationLabel.text = @"PortraitUpsideDown";
                    break;
                case MBLAccelerometerOrientationLandscapeLeft:
                    self.orientationLabel.text = @"LandscapeLeft";
                    break;
                case MBLAccelerometerOrientationLandscapeRight:
                    self.orientationLabel.text = @"LandscapeRight";
                    break;
            }
        }
    }];
}

- (IBAction)stopOrientationPressed:(id)sender
{
    [self.startOrientation setEnabled:YES];
    [self.stopOrientation setEnabled:NO];
    
    MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerMMA8452Q.orientationEvent];
    [accelerometerMMA8452Q.orientationEvent stopNotificationsAsync];
    self.orientationLabel.text = @"XXXXXXXXXXXXXX";
}


- (void)updateAccelerometerBMI160Settings
{
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    switch (self.accelerometerBMI160Scale.selectedSegmentIndex) {
        case 0:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBoschRange2G;
            self.accelerometerBMI160Graph.fullScale = 2;
            break;
        case 1:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBoschRange4G;
            self.accelerometerBMI160Graph.fullScale = 4;
            break;
        case 2:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBoschRange8G;
            self.accelerometerBMI160Graph.fullScale = 8;
            break;
        case 3:
            accelerometerBMI160.fullScaleRange = MBLAccelerometerBoschRange16G;
            self.accelerometerBMI160Graph.fullScale = 16;
            break;
        default:
            NSLog(@"Unexpected accelerometerBMI160Scale value");
            break;
    }
    
    accelerometerBMI160.sampleFrequency = [[self.accelerometerBMI160Frequency titleForSegmentAtIndex:self.accelerometerBMI160Frequency.selectedSegmentIndex] floatValue];
    accelerometerBMI160.tapType = (int)self.tapDetectionType.selectedSegmentIndex;
}

- (IBAction)accelerometerBMI160StartStreamPressed:(id)sender
{
    [self.accelerometerBMI160StartStream setEnabled:NO];
    [self.accelerometerBMI160StopStream setEnabled:YES];
    [self.accelerometerBMI160StartLog setEnabled:NO];
    [self.accelerometerBMI160StopLog setEnabled:NO];
    
    [self updateAccelerometerBMI160Settings];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.accelerometerBMI160Data = array;
    
    [self.streamingEvents addObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            [self.accelerometerBMI160Graph addX:obj.x y:obj.y z:obj.z];
            [array addObject:obj];
        }
    }];
}

- (IBAction)accelerometerBMI160StopStreamPressed:(id)sender
{
    [self.accelerometerBMI160StartStream setEnabled:YES];
    [self.accelerometerBMI160StopStream setEnabled:NO];
    [self.accelerometerBMI160StartLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
}

- (IBAction)accelerometerBMI160StartLogPressed:(id)sender
{
    [self.accelerometerBMI160StartLog setEnabled:NO];
    [self.accelerometerBMI160StopLog setEnabled:YES];
    [self.accelerometerBMI160StartStream setEnabled:NO];
    [self.accelerometerBMI160StopStream setEnabled:NO];
    
    [self updateAccelerometerBMI160Settings];
    
    [self.device.accelerometer.dataReadyEvent startLoggingAsync];
}

- (IBAction)accelerometerBMI160StopLogPressed:(id)sender
{
    [self.accelerometerBMI160StartLog setEnabled:YES];
    [self.accelerometerBMI160StopLog setEnabled:NO];
    [self.accelerometerBMI160StartStream setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Downloading...";
    
    [[[self.device.accelerometer.dataReadyEvent downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
        hud.progress = number;
    }] success:^(NSArray<MBLAccelerometerData *> * _Nonnull array) {
        self.accelerometerBMI160Data = array;
        for (MBLAccelerometerData *obj in array) {
            [self.accelerometerBMI160Graph addX:obj.x y:obj.y z:obj.z];
        }
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Clearing Log...";
        [self logCleanup:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error) {
                [self connectDevice:NO];
            }
        }];
    }] failure:^(NSError * _Nonnull error) {
        [self connectDevice:NO];
        [hud hideAnimated:YES];
    }];
}

- (IBAction)accelerometerBMI160EmailDataPressed:(id)sender
{
    NSMutableData *accelerometerData = [NSMutableData data];
    for (MBLAccelerometerData *dataElement in self.accelerometerBMI160Data) {
        @autoreleasepool {
            [accelerometerData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                            dataElement.timestamp.timeIntervalSince1970,
                                            dataElement.x,
                                            dataElement.y,
                                            dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendData:accelerometerData title:@"AccData"];
}

- (IBAction)accelerometerBMI160StartTapPressed:(id)sender
{
    [self.accelerometerBMI160StartTap setEnabled:NO];
    [self.accelerometerBMI160StopTap setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.tapEvent];
    [accelerometerBMI160.tapEvent startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.accelerometerBMI160TapLabel.text = [NSString stringWithFormat:@"Tap Count: %d", ++self.accelerometerBMI160TapCount];
        }
    }];
}

- (IBAction)accelerometerBMI160StopTapPressed:(id)sender
{
    [self.accelerometerBMI160StartTap setEnabled:YES];
    [self.accelerometerBMI160StopTap setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.tapEvent];
    [accelerometerBMI160.tapEvent stopNotificationsAsync];
    self.accelerometerBMI160TapCount = 0;
    self.accelerometerBMI160TapLabel.text = @"Tap Count: 0";
}

- (IBAction)accelerometerBMI160StartFlatPressed:(id)sender
{
    [self.accelerometerBMI160StartFlat setEnabled:NO];
    [self.accelerometerBMI160StopFlat setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.flatEvent];
    [accelerometerBMI160.flatEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.accelerometerBMI160FlatLabel.text = obj.value.boolValue ? @"Flat" : @"Not Flat";
        }
    }];
}

- (IBAction)accelerometerBMI160StopFlatPressed:(id)sender
{
    [self.accelerometerBMI160StartFlat setEnabled:YES];
    [self.accelerometerBMI160StopFlat setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.flatEvent];
    [accelerometerBMI160.flatEvent stopNotificationsAsync];
    self.accelerometerBMI160FlatLabel.text = @"XXXXXXX";
}

- (IBAction)accelerometerBMI160StartOrientPressed:(id)sender
{
    [self.accelerometerBMI160StartOrient setEnabled:NO];
    [self.accelerometerBMI160StopOrient setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.orientationEvent];
    [accelerometerBMI160.orientationEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            switch (obj.orientation) {
                case MBLAccelerometerOrientationPortrait:
                    self.accelerometerBMI160OrientLabel.text = @"Portrait";
                    break;
                case MBLAccelerometerOrientationPortraitUpsideDown:
                    self.accelerometerBMI160OrientLabel.text = @"PortraitUpsideDown";
                    break;
                case MBLAccelerometerOrientationLandscapeLeft:
                    self.accelerometerBMI160OrientLabel.text = @"LandscapeLeft";
                    break;
                case MBLAccelerometerOrientationLandscapeRight:
                    self.accelerometerBMI160OrientLabel.text = @"LandscapeRight";
                    break;
            }
        }
    }];
}

- (IBAction)accelerometerBMI160StopOrientPressed:(id)sender
{
    [self.accelerometerBMI160StartOrient setEnabled:YES];
    [self.accelerometerBMI160StopOrient setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.orientationEvent];
    [accelerometerBMI160.orientationEvent stopNotificationsAsync];
    self.accelerometerBMI160OrientLabel.text = @"XXXXXXXXXXXXXX";
}

- (IBAction)accelerometerBMI160StartStepPressed:(id)sender
{
    [self.accelerometerBMI160StartStep setEnabled:NO];
    [self.accelerometerBMI160StopStep setEnabled:YES];
    
    [self updateAccelerometerBMI160Settings];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMI160.stepEvent];
    [accelerometerBMI160.stepEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.accelerometerBMI160StepLabel.text = [NSString stringWithFormat:@"Step Count: %d", ++self.accelerometerBMI160StepCount];
        }
    }];
}

- (IBAction)accelerometerBMI160StopStepPressed:(id)sender
{
    [self.accelerometerBMI160StartStep setEnabled:YES];
    [self.accelerometerBMI160StopStep setEnabled:NO];
    
    MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMI160.stepEvent];
    [accelerometerBMI160.stepEvent stopNotificationsAsync];
    self.accelerometerBMI160StepCount = 0;
    self.accelerometerBMI160StepLabel.text = @"Step Count: 0";
}


- (void)updateaccelerometerBMA255Settings
{
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    switch (self.accelerometerBMA255Scale.selectedSegmentIndex) {
        case 0:
            accelerometerBMA255.fullScaleRange = MBLAccelerometerBoschRange2G;
            self.accelerometerBMA255Graph.fullScale = 2;
            break;
        case 1:
            accelerometerBMA255.fullScaleRange = MBLAccelerometerBoschRange4G;
            self.accelerometerBMA255Graph.fullScale = 4;
            break;
        case 2:
            accelerometerBMA255.fullScaleRange = MBLAccelerometerBoschRange8G;
            self.accelerometerBMA255Graph.fullScale = 8;
            break;
        case 3:
            accelerometerBMA255.fullScaleRange = MBLAccelerometerBoschRange16G;
            self.accelerometerBMA255Graph.fullScale = 16;
            break;
        default:
            NSLog(@"Unexpected accelerometerBMA255Scale value");
            break;
    }
    
    accelerometerBMA255.sampleFrequency = [[self.accelerometerBMA255Frequency titleForSegmentAtIndex:self.accelerometerBMA255Frequency.selectedSegmentIndex] floatValue];
    accelerometerBMA255.tapType = (int)self.tapDetectionType.selectedSegmentIndex;
}

- (IBAction)accelerometerBMA255StartStreamPressed:(id)sender
{
    [self.accelerometerBMA255StartStream setEnabled:NO];
    [self.accelerometerBMA255StopStream setEnabled:YES];
    [self.accelerometerBMA255StartLog setEnabled:NO];
    [self.accelerometerBMA255StopLog setEnabled:NO];
    
    [self updateaccelerometerBMA255Settings];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.accelerometerBMA255Data = array;
    
    [self.streamingEvents addObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            [self.accelerometerBMA255Graph addX:obj.x y:obj.y z:obj.z];
            [array addObject:obj];
        }
    }];
}

- (IBAction)accelerometerBMA255StopStreamPressed:(id)sender
{
    [self.accelerometerBMA255StartStream setEnabled:YES];
    [self.accelerometerBMA255StopStream setEnabled:NO];
    [self.accelerometerBMA255StartLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.accelerometer.dataReadyEvent];
    [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
}

- (IBAction)accelerometerBMA255StartLogPressed:(id)sender
{
    [self.accelerometerBMA255StartLog setEnabled:NO];
    [self.accelerometerBMA255StopLog setEnabled:YES];
    [self.accelerometerBMA255StartStream setEnabled:NO];
    [self.accelerometerBMA255StopStream setEnabled:NO];
    
    [self updateaccelerometerBMA255Settings];
    
    [self.device.accelerometer.dataReadyEvent startLoggingAsync];
}

- (IBAction)accelerometerBMA255StopLogPressed:(id)sender
{
    [self.accelerometerBMA255StartLog setEnabled:YES];
    [self.accelerometerBMA255StopLog setEnabled:NO];
    [self.accelerometerBMA255StartStream setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Downloading...";
    
    [[[self.device.accelerometer.dataReadyEvent downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
        hud.progress = number;
    }] success:^(NSArray<MBLAccelerometerData *> * _Nonnull array) {
        self.accelerometerBMA255Data = array;
        for (MBLAccelerometerData *obj in array) {
            [self.accelerometerBMA255Graph addX:obj.x y:obj.y z:obj.z];
        }
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Clearing Log...";
        [self logCleanup:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error) {
                [self connectDevice:NO];
            }
        }];
    }] failure:^(NSError * _Nonnull error) {
        [self connectDevice:NO];
        [hud hideAnimated:YES];
    }];
}

- (IBAction)accelerometerBMA255EmailDataPressed:(id)sender
{
    NSMutableData *accelerometerData = [NSMutableData data];
    for (MBLAccelerometerData *dataElement in self.accelerometerBMA255Data) {
        @autoreleasepool {
            [accelerometerData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                            dataElement.timestamp.timeIntervalSince1970,
                                            dataElement.x,
                                            dataElement.y,
                                            dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendData:accelerometerData title:@"AccData"];
}

- (IBAction)accelerometerBMA255StartTapPressed:(id)sender
{
    [self.accelerometerBMA255StartTap setEnabled:NO];
    [self.accelerometerBMA255StopTap setEnabled:YES];
    
    [self updateaccelerometerBMA255Settings];
    
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMA255.tapEvent];
    [accelerometerBMA255.tapEvent startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.accelerometerBMA255TapLabel.text = [NSString stringWithFormat:@"Tap Count: %d", ++self.accelerometerBMA255TapCount];
        }
    }];
}

- (IBAction)accelerometerBMA255StopTapPressed:(id)sender
{
    [self.accelerometerBMA255StartTap setEnabled:YES];
    [self.accelerometerBMA255StopTap setEnabled:NO];
    
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMA255.tapEvent];
    [accelerometerBMA255.tapEvent stopNotificationsAsync];
    self.accelerometerBMA255TapCount = 0;
    self.accelerometerBMA255TapLabel.text = @"Tap Count: 0";
}

- (IBAction)accelerometerBMA255StartFlatPressed:(id)sender
{
    [self.accelerometerBMA255StartFlat setEnabled:NO];
    [self.accelerometerBMA255StopFlat setEnabled:YES];
    
    [self updateaccelerometerBMA255Settings];
    
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMA255.flatEvent];
    [accelerometerBMA255.flatEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.accelerometerBMA255FlatLabel.text = obj.value.boolValue ? @"Flat" : @"Not Flat";
        }
    }];
}

- (IBAction)accelerometerBMA255StopFlatPressed:(id)sender
{
    [self.accelerometerBMA255StartFlat setEnabled:YES];
    [self.accelerometerBMA255StopFlat setEnabled:NO];
    
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMA255.flatEvent];
    [accelerometerBMA255.flatEvent stopNotificationsAsync];
    self.accelerometerBMA255FlatLabel.text = @"XXXXXXX";
}

- (IBAction)accelerometerBMA255StartOrientPressed:(id)sender
{
    [self.accelerometerBMA255StartOrient setEnabled:NO];
    [self.accelerometerBMA255StopOrient setEnabled:YES];
    
    [self updateaccelerometerBMA255Settings];
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    [self.streamingEvents addObject:accelerometerBMA255.orientationEvent];
    [accelerometerBMA255.orientationEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            switch (obj.orientation) {
                case MBLAccelerometerOrientationPortrait:
                    self.accelerometerBMA255OrientLabel.text = @"Portrait";
                    break;
                case MBLAccelerometerOrientationPortraitUpsideDown:
                    self.accelerometerBMA255OrientLabel.text = @"PortraitUpsideDown";
                    break;
                case MBLAccelerometerOrientationLandscapeLeft:
                    self.accelerometerBMA255OrientLabel.text = @"LandscapeLeft";
                    break;
                case MBLAccelerometerOrientationLandscapeRight:
                    self.accelerometerBMA255OrientLabel.text = @"LandscapeRight";
                    break;
            }
        }
    }];
}

- (IBAction)accelerometerBMA255StopOrientPressed:(id)sender
{
    [self.accelerometerBMA255StartOrient setEnabled:YES];
    [self.accelerometerBMA255StopOrient setEnabled:NO];
    
    MBLAccelerometerBMA255 *accelerometerBMA255 = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    [self.streamingEvents removeObject:accelerometerBMA255.orientationEvent];
    [accelerometerBMA255.orientationEvent stopNotificationsAsync];
    self.accelerometerBMA255OrientLabel.text = @"XXXXXXXXXXXXXX";
}


- (void)updateGyroBMI160Settings
{
    MBLGyroBMI160 *gyroBMI160 = (MBLGyroBMI160 *)self.device.gyro;
    switch (self.gyroBMI160Scale.selectedSegmentIndex) {
        case 0:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range125;
            self.gyroBMI160Graph.fullScale = 1;
            break;
        case 1:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range250;
            self.gyroBMI160Graph.fullScale = 2;
            break;
        case 2:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range500;
            self.gyroBMI160Graph.fullScale = 4;
            break;
        case 3:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range1000;
            self.gyroBMI160Graph.fullScale = 8;
            break;
        case 4:
            gyroBMI160.fullScaleRange = MBLGyroBMI160Range2000;
            self.gyroBMI160Graph.fullScale = 16;
            break;
        default:
            NSLog(@"Unexpected gyroBMI160Scale value");
            break;
    }
    gyroBMI160.sampleFrequency = [[self.gyroBMI160Frequency titleForSegmentAtIndex:self.gyroBMI160Frequency.selectedSegmentIndex] floatValue];
}

- (IBAction)gyroBMI160StartStreamPressed:(id)sender
{
    [self.gyroBMI160StartStream setEnabled:NO];
    [self.gyroBMI160StopStream setEnabled:YES];
    [self.gyroBMI160StartLog setEnabled:NO];
    [self.gyroBMI160StopLog setEnabled:NO];
    
    [self updateGyroBMI160Settings];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.gyroBMI160Data = array;
    
    [self.streamingEvents addObject:self.device.gyro.dataReadyEvent];
    [self.device.gyro.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLGyroData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            // TODO: Come up with a better graph interface, we need to scale value
            // to show up right
            [self.gyroBMI160Graph addX:obj.x * .008 y:obj.y * .008 z:obj.z * .008];
            [array addObject:obj];
        }
    }];
}

- (IBAction)gyroBMI160StopStreamPressed:(id)sender
{
    [self.gyroBMI160StartStream setEnabled:YES];
    [self.gyroBMI160StopStream setEnabled:NO];
    [self.gyroBMI160StartLog setEnabled:YES];
    
    [self.streamingEvents removeObject:self.device.gyro.dataReadyEvent];
    [self.device.gyro.dataReadyEvent stopNotificationsAsync];
}

- (IBAction)gyroBMI160StartLogPressed:(id)sender
{
    [self.gyroBMI160StartLog setEnabled:NO];
    [self.gyroBMI160StopLog setEnabled:YES];
    [self.gyroBMI160StartStream setEnabled:NO];
    [self.gyroBMI160StopStream setEnabled:NO];
    
    [self updateGyroBMI160Settings];
    
    [self.device.gyro.dataReadyEvent startLoggingAsync];
}

- (IBAction)gyroBMI160StopLogPressed:(id)sender
{
    [self.gyroBMI160StartLog setEnabled:YES];
    [self.gyroBMI160StopLog setEnabled:NO];
    [self.gyroBMI160StartStream setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Downloading...";
    
    [[[self.device.gyro.dataReadyEvent downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
        hud.progress = number;
    }] success:^(NSArray<MBLGyroData *> * _Nonnull array) {
        self.gyroBMI160Data = array;
        for (MBLGyroData *obj in array) {
            [self.gyroBMI160Graph addX:obj.x * .008 y:obj.y * .008 z:obj.z * .008];
        }
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Clearing Log...";
        [self logCleanup:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error) {
                [self connectDevice:NO];
            }
        }];
    }] failure:^(NSError * _Nonnull error) {
        [self connectDevice:NO];
        [hud hideAnimated:YES];
    }];
}

- (IBAction)gyroBMI160EmailDataPressed:(id)sender
{
    NSMutableData *gyroData = [NSMutableData data];
    for (MBLGyroData *dataElement in self.gyroBMI160Data) {
        @autoreleasepool {
            [gyroData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                   dataElement.timestamp.timeIntervalSince1970,
                                   dataElement.x,
                                   dataElement.y,
                                   dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendData:gyroData title:@"GyroData"];
}

- (IBAction)magnetometerBMM150StartStreamPressed:(id)sender
{
    [self.magnetometerBMM150StartStream setEnabled:NO];
    [self.magnetometerBMM150StopStream setEnabled:YES];
    [self.magnetometerBMM150StartLog setEnabled:NO];
    [self.magnetometerBMM150StopLog setEnabled:NO];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:1000];
    self.magnetometerBMM150Data = array;
    
    self.magnetometerBMM150Graph.fullScale = 4;
    
    MBLMagnetometerBMM150 *magnetometerBMM150 = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    [self.streamingEvents addObject:magnetometerBMM150.periodicMagneticField];
    [magnetometerBMM150.periodicMagneticField startNotificationsWithHandlerAsync:^(MBLGyroData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            // TODO: Come up with a better graph interface, we need to scale value
            // to show up right
            [self.magnetometerBMM150Graph addX:obj.x * 20000.0 y:obj.y * 20000.0 z:obj.z * 20000.0];
            [array addObject:obj];
        }
    }];
}

- (IBAction)magnetometerBMM150StopStreamPressed:(id)sender
{
    [self.magnetometerBMM150StartStream setEnabled:YES];
    [self.magnetometerBMM150StopStream setEnabled:NO];
    [self.magnetometerBMM150StartLog setEnabled:YES];
    
    MBLMagnetometerBMM150 *magnetometerBMM150 = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    [self.streamingEvents removeObject:magnetometerBMM150.periodicMagneticField];
    [magnetometerBMM150.periodicMagneticField stopNotificationsAsync];
}

- (IBAction)magnetometerBMM150StartLogPressed:(id)sender
{
    [self.magnetometerBMM150StartLog setEnabled:NO];
    [self.magnetometerBMM150StopLog setEnabled:YES];
    [self.magnetometerBMM150StartStream setEnabled:NO];
    [self.magnetometerBMM150StopStream setEnabled:NO];
    
    self.magnetometerBMM150Graph.fullScale = 4;

    MBLMagnetometerBMM150 *magnetometerBMM150 = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    [magnetometerBMM150.periodicMagneticField startLoggingAsync];
}

- (IBAction)magnetometerBMM150StopLogPressed:(id)sender
{
    [self.magnetometerBMM150StartLog setEnabled:YES];
    [self.magnetometerBMM150StopLog setEnabled:NO];
    [self.magnetometerBMM150StartStream setEnabled:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Downloading...";
    
    MBLMagnetometerBMM150 *magnetometerBMM150 = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    [[[magnetometerBMM150.periodicMagneticField downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
        hud.progress = number;
    }] success:^(NSArray<MBLMagnetometerData *> * _Nonnull array) {
        self.magnetometerBMM150Data = array;
        for (MBLMagnetometerData *obj in array) {
            [self.magnetometerBMM150Graph addX:obj.x * 20000.0 y:obj.y * 20000.0 z:obj.z * 20000.0];
        }
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Clearing Log...";
        [self logCleanup:^(NSError *error) {
            [hud hideAnimated:YES];
            if (error) {
                [self connectDevice:NO];
            }
        }];
    }] failure:^(NSError * _Nonnull error) {
        [self connectDevice:NO];
        [hud hideAnimated:YES];
    }];
}

- (IBAction)magnetometerBMM150SendDataPressed:(id)sender
{
    NSMutableData *magnetometerData = [NSMutableData data];
    for (MBLMagnetometerData *dataElement in self.magnetometerBMM150Data) {
        @autoreleasepool {
            [magnetometerData appendData:[[NSString stringWithFormat:@"%f,%f,%f,%f\n",
                                           dataElement.timestamp.timeIntervalSince1970,
                                           dataElement.x,
                                           dataElement.y,
                                           dataElement.z] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [self sendData:magnetometerData title:@"MagnetometerData"];
}

- (IBAction)gpioPinSelectorPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    if (pin.analogAbsolute) {
        [self.gpioAnalogAbsoluteButton setHidden:NO];
        [self.gpioAnalogAbsoluteValue setHidden:NO];
    } else {
        [self.gpioAnalogAbsoluteButton setHidden:YES];
        [self.gpioAnalogAbsoluteValue setHidden:YES];
    }
    if (pin.analogRatio) {
        [self.gpioAnalogRatioButton setHidden:NO];
        [self.gpioAnalogRatioValue setHidden:NO];
    } else {
        [self.gpioAnalogRatioButton setHidden:YES];
        [self.gpioAnalogRatioValue setHidden:YES];
    }
}

- (IBAction)setPullUpPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    pin.configuration = MBLPinConfigurationPullup;
}

- (IBAction)setPullDownPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    pin.configuration = MBLPinConfigurationPulldown;
}

- (IBAction)setNoPullPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    pin.configuration = MBLPinConfigurationNopull;
}

- (IBAction)setPinPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin setToDigitalValueAsync:YES];
}

- (IBAction)clearPinPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [pin setToDigitalValueAsync:NO];
}

- (IBAction)gpioStartPinChangePressed:(id)sender
{
    [self.gpioStartPinChange setEnabled:NO];
    [self.gpioStopPinChange setEnabled:YES];
    
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    if (self.gpioPinChangeType.selectedSegmentIndex == 0) {
        pin.changeType = MBLPinChangeTypeRising;
    } else if (self.gpioPinChangeType.selectedSegmentIndex == 1) {
        pin.changeType = MBLPinChangeTypeFalling;
    } else {
        pin.changeType = MBLPinChangeTypeAny;
    }
    [self.streamingEvents addObject:pin.changeEvent];
    [pin.changeEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.gpioPinChangeLabel.text = [NSString stringWithFormat:@"Change Count: %d", ++self.gpioPinChangeCount];
        }
    }];
}

- (IBAction)gpioStopPinChangePressed:(id)sender
{
    [self.gpioStartPinChange setEnabled:YES];
    [self.gpioStopPinChange setEnabled:NO];
    
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [self.streamingEvents removeObject:pin.changeEvent];
    [pin.changeEvent stopNotificationsAsync];
    self.gpioPinChangeCount = 0;
    self.gpioPinChangeLabel.text = @"Change Count: 0";
}

- (IBAction)readDigitalPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [[pin.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        self.gpioDigitalValue.text = result.value.boolValue ? @"1" : @"0";
    }];
}

- (IBAction)readAnalogAbsolutePressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [[pin.analogAbsolute readAsync] success:^(MBLNumericData * _Nonnull result) {
        self.gpioAnalogAbsoluteValue.text = [NSString stringWithFormat:@"%.3fV", result.value.doubleValue];
    }];
}
- (IBAction)readAnalogRatioPressed:(id)sender
{
    MBLGPIOPin *pin = self.device.gpio.pins[self.gpioPinSelector.selectedSegmentIndex];
    [[pin.analogRatio readAsync] success:^(MBLNumericData * _Nonnull result) {
        self.gpioAnalogRatioValue.text = [NSString stringWithFormat:@"%.3f", result.value.doubleValue];
    }];
}


- (IBAction)startHapticDriverPressed:(UIButton *)sender
{
    int dcycle = [self.hapticDutyCycle.text intValue];
    dcycle = MIN(dcycle, 248);
    dcycle = MAX(dcycle, 0);
    int pwidth = [self.hapticPulseWidth.text intValue];
    pwidth = MIN(pwidth, 10000);
    pwidth = MAX(pwidth, 0);
    
    [sender setEnabled:NO];
    [self.device.hapticBuzzer startHapticWithDutyCycleAsync:dcycle pulseWidth:pwidth completion:^{
        [sender setEnabled:YES];
    }];
}

- (IBAction)startBuzzerDriverPressed:(UIButton *)sender
{
    int pwidth = [self.hapticPulseWidth.text intValue];
    pwidth = MIN(pwidth, 10000);
    pwidth = MAX(pwidth, 0);
    
    [sender setEnabled:NO];
    [self.device.hapticBuzzer startBuzzerWithPulseWidthAsync:pwidth completion:^{
        [sender setEnabled:YES];
    }];
}


- (IBAction)startiBeaconPressed:(id)sender
{
    // TODO: Expose the other iBeacon parameters
    [self.device.iBeacon setBeaconOnAsync:YES];
}

- (IBAction)stopiBeaconPressed:(id)sender
{
    [self.device.iBeacon setBeaconOnAsync:NO];
}


- (IBAction)barometerBMP280StartStreamPressed:(id)sender
{
    [self.barometerBMP280StartStream setEnabled:NO];
    [self.barometerBMP280StopStream setEnabled:YES];
    
    MBLBarometerBMP280 *barometerBMP280 = (MBLBarometerBMP280 *)self.device.barometer;
    if (self.barometerBMP280Oversampling.selectedSegmentIndex == 0) {
        barometerBMP280.pressureOversampling = MBLBarometerBoschOversampleUltraLowPower;
    } else if (self.barometerBMP280Oversampling.selectedSegmentIndex == 1) {
        barometerBMP280.pressureOversampling = MBLBarometerBoschOversampleLowPower;
    } else if (self.barometerBMP280Oversampling.selectedSegmentIndex == 2) {
        barometerBMP280.pressureOversampling = MBLBarometerBoschOversampleStandard;
    } else if (self.barometerBMP280Oversampling.selectedSegmentIndex == 3) {
        barometerBMP280.pressureOversampling = MBLBarometerBoschOversampleHighResolution;
    } else {
        barometerBMP280.pressureOversampling = MBLBarometerBoschOversampleUltraHighResolution;
    }
    
    if (self.barometerBMP280Averaging.selectedSegmentIndex == 0) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBoschFilterOff;
    } else if (self.barometerBMP280Averaging.selectedSegmentIndex == 1) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBoschFilterAverage2;
    } else if (self.barometerBMP280Averaging.selectedSegmentIndex == 2) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBoschFilterAverage4;
    } else if (self.barometerBMP280Averaging.selectedSegmentIndex == 3) {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBoschFilterAverage8;
    } else {
        barometerBMP280.hardwareAverageFilter = MBLBarometerBoschFilterAverage16;
    }
    
    if (self.barometerBMP280Standby.selectedSegmentIndex == 0) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby0_5;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 1) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby62_5;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 2) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby125;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 3) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby250;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 4) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby500;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 5) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby1000;
    } else if (self.barometerBMP280Standby.selectedSegmentIndex == 6) {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby2000;
    } else {
        barometerBMP280.standbyTime = MBLBarometerBMP280Standby4000;
    }
    
    [self.streamingEvents addObject:barometerBMP280.periodicAltitude];
    [barometerBMP280.periodicAltitude startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.barometerBMP280Altitude.text = [NSString stringWithFormat:@"%.3f", obj.value.floatValue];
        }
    }];
}

- (IBAction)barometerBMP280StopStreamPressed:(id)sender
{
    [self.barometerBMP280StartStream setEnabled:YES];
    [self.barometerBMP280StopStream setEnabled:NO];
    
    MBLBarometerBMP280 *barometerBMP280 = (MBLBarometerBMP280 *)self.device.barometer;
    [self.streamingEvents removeObject:barometerBMP280.periodicAltitude];
    [barometerBMP280.periodicAltitude stopNotificationsAsync];
    self.barometerBMP280Altitude.text = @"X.XXX";
}


- (IBAction)barometerBME280StartStreamPressed:(id)sender
{
    [self.barometerBME280StartStream setEnabled:NO];
    [self.barometerBME280StopStream setEnabled:YES];
    
    MBLBarometerBME280 *barometerBME280 = (MBLBarometerBME280 *)self.device.barometer;
    if (self.barometerBMP280Oversampling.selectedSegmentIndex == 0) {
        barometerBME280.pressureOversampling = MBLBarometerBoschOversampleUltraLowPower;
    } else if (self.barometerBME280Oversampling.selectedSegmentIndex == 1) {
        barometerBME280.pressureOversampling = MBLBarometerBoschOversampleLowPower;
    } else if (self.barometerBME280Oversampling.selectedSegmentIndex == 2) {
        barometerBME280.pressureOversampling = MBLBarometerBoschOversampleStandard;
    } else if (self.barometerBME280Oversampling.selectedSegmentIndex == 3) {
        barometerBME280.pressureOversampling = MBLBarometerBoschOversampleHighResolution;
    } else {
        barometerBME280.pressureOversampling = MBLBarometerBoschOversampleUltraHighResolution;
    }
    
    if (self.barometerBME280Averaging.selectedSegmentIndex == 0) {
        barometerBME280.hardwareAverageFilter = MBLBarometerBoschFilterOff;
    } else if (self.barometerBME280Averaging.selectedSegmentIndex == 1) {
        barometerBME280.hardwareAverageFilter = MBLBarometerBoschFilterAverage2;
    } else if (self.barometerBME280Averaging.selectedSegmentIndex == 2) {
        barometerBME280.hardwareAverageFilter = MBLBarometerBoschFilterAverage4;
    } else if (self.barometerBME280Averaging.selectedSegmentIndex == 3) {
        barometerBME280.hardwareAverageFilter = MBLBarometerBoschFilterAverage8;
    } else {
        barometerBME280.hardwareAverageFilter = MBLBarometerBoschFilterAverage16;
    }
    
    if (self.barometerBME280Standby.selectedSegmentIndex == 0) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby0_5;
    } else if (self.barometerBME280Standby.selectedSegmentIndex == 1) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby10;
    } else if (self.barometerBME280Standby.selectedSegmentIndex == 2) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby20;
    } else if (self.barometerBME280Standby.selectedSegmentIndex == 3) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby62_5;
    } else if (self.barometerBME280Standby.selectedSegmentIndex == 4) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby125;
    } else if (self.barometerBME280Standby.selectedSegmentIndex == 5) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby250;
    } else if (self.barometerBME280Standby.selectedSegmentIndex == 6) {
        barometerBME280.standbyTime = MBLBarometerBME280Standby500;
    } else {
        barometerBME280.standbyTime = MBLBarometerBME280Standby1000;
    }
    
    [self.streamingEvents addObject:barometerBME280.periodicAltitude];
    [barometerBME280.periodicAltitude startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.barometerBME280Altitude.text = [NSString stringWithFormat:@"%.3f", obj.value.floatValue];
        }
    }];
}

- (IBAction)barometerBME280StopStreamPressed:(id)sender
{
    [self.barometerBME280StartStream setEnabled:YES];
    [self.barometerBME280StopStream setEnabled:NO];
    
    MBLBarometerBME280 *barometerBME280 = (MBLBarometerBME280 *)self.device.barometer;
    [self.streamingEvents removeObject:barometerBME280.periodicAltitude];
    [barometerBME280.periodicAltitude stopNotificationsAsync];
    self.barometerBME280Altitude.text = @"X.XXX";
}


- (IBAction)ambientLightLTR329StartStreamPressed:(id)sender
{
    [self.ambientLightLTR329StartStream setEnabled:NO];
    [self.ambientLightLTR329StopStream setEnabled:YES];
    
    MBLAmbientLightLTR329 *ambientLightLTR329 = (MBLAmbientLightLTR329 *)self.device.ambientLight;
    switch (self.ambientLightLTR329Gain.selectedSegmentIndex) {
        case 0:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain1X;
            break;
        case 1:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain2X;
            break;
        case 2:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain4X;
            break;
        case 3:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain8X;
            break;
        case 4:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain48X;
            break;
        default:
            ambientLightLTR329.gain = MBLAmbientLightLTR329Gain96X;
            break;
    }
    
    switch (self.ambientLightLTR329Integration.selectedSegmentIndex) {
        case 0:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration50ms;
            break;
        case 1:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration100ms;
            break;
        case 2:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration150ms;
            break;
        case 3:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration200ms;
            break;
        case 4:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration250ms;
            break;
        case 5:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration300ms;
            break;
        case 6:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration350ms;
            break;
        default:
            ambientLightLTR329.integrationTime = MBLAmbientLightLTR329Integration400ms;
            break;
    }
    
    switch (self.ambientLightLTR329Measurement.selectedSegmentIndex) {
        case 0:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate50ms;
            break;
        case 1:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate100ms;
            break;
        case 2:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate200ms;
            break;
        case 3:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate500ms;
            break;
        case 4:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate1000ms;
            break;
        default:
            ambientLightLTR329.measurementRate = MBLAmbientLightLTR329Rate2000ms;
            break;
    }
    
    [self.streamingEvents addObject:ambientLightLTR329.periodicIlluminance];
    [ambientLightLTR329.periodicIlluminance startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.ambientLightLTR329Illuminance.text = [NSString stringWithFormat:@"%.3f", obj.value.floatValue];
        }
    }];
}

- (IBAction)ambientLightLTR329StopStreamPressed:(id)sender
{
    [self.ambientLightLTR329StartStream setEnabled:YES];
    [self.ambientLightLTR329StopStream setEnabled:NO];
    
    MBLAmbientLightLTR329 *ambientLightLTR329 = (MBLAmbientLightLTR329 *)self.device.ambientLight;
    [self.streamingEvents removeObject:ambientLightLTR329.periodicIlluminance];
    [ambientLightLTR329.periodicIlluminance stopNotificationsAsync];
    self.ambientLightLTR329Illuminance.text = @"X.XXX";
}


- (IBAction)proximityTSL2671IntegrationSliderChanged:(id)sender
{
    self.proximityTSL2671IntegrationLabel.text = [NSString stringWithFormat:@"%.2f", self.proximityTSL2671IntegrationSlider.value];
}

- (IBAction)proximityTSL2671PulseStepperChanged:(id)sender
{
    self.proximityTSL2671PulseLabel.text = [NSString stringWithFormat:@"%d", (int)round(self.proximityTSL2671PulseStepper.value)];
}

- (IBAction)proximityTSL2671StartStreamPressed:(id)sender
{
    [self.proximityTSL2671StartStream setEnabled:NO];
    [self.proximityTSL2671StopStream setEnabled:YES];
    [self.proximityTSL2671Drive setEnabled:NO];
    [self.proximityTSL2671IntegrationSlider setEnabled:NO];
    [self.proximityTSL2671PulseStepper setEnabled:NO];
    
    MBLProximityTSL2671 *proximityTSL2671 = (MBLProximityTSL2671 *)self.device.proximity;
    switch (self.proximityTSL2671Drive.selectedSegmentIndex) {
        case 0:
            proximityTSL2671.drive = MBLProximityTSL2671TransmitterDrive12_5mA;
            break;
        default:
            proximityTSL2671.drive = MBLProximityTSL2671TransmitterDrive25mA;
            break;
    }
    proximityTSL2671.integrationTime = self.proximityTSL2671IntegrationSlider.value;
    proximityTSL2671.proximityPulses = round(self.proximityTSL2671PulseStepper.value);
    
    self.proximityTSL2671Event = [proximityTSL2671.proximity periodicReadWithPeriod:700];
    [self.streamingEvents addObject:self.proximityTSL2671Event];
    [self.proximityTSL2671Event startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.proximityTSL2671Proximity.text = [NSString stringWithFormat:@"%d", obj.value.intValue];
        }
    }];
}

- (IBAction)proximityTSL2671StopStreamPressed:(id)sender
{
    [self.proximityTSL2671StartStream setEnabled:YES];
    [self.proximityTSL2671StopStream setEnabled:NO];
    [self.proximityTSL2671Drive setEnabled:YES];
    [self.proximityTSL2671IntegrationSlider setEnabled:YES];
    [self.proximityTSL2671PulseStepper setEnabled:YES];
    
    [self.streamingEvents removeObject:self.proximityTSL2671Event];
    [self.proximityTSL2671Event stopNotificationsAsync];
    self.proximityTSL2671Proximity.text = @"XXXX";
}


- (IBAction)photometerTCS3472IntegrationSliderChanged:(id)sender
{
    self.photometerTCS3472IntegrationLabel.text = [NSString stringWithFormat:@"%.1f", self.photometerTCS3472IntegrationSlider.value];
}

- (IBAction)photometerTCS3472StartStreamPressed:(id)sender
{
    [self.photometerTCS3472StartStream setEnabled:NO];
    [self.photometerTCS3472StopStream setEnabled:YES];
    [self.photometerTCS3472Gain setEnabled:NO];
    [self.photometerTCS3472IntegrationSlider setEnabled:NO];
    [self.photometerTCS3472LedFlashSwitch setEnabled:NO];
    
    MBLPhotometerTCS3472 *photometerTCS3472 = (MBLPhotometerTCS3472 *)self.device.photometer;
    switch (self.photometerTCS3472Gain.selectedSegmentIndex) {
        case 0:
            photometerTCS3472.gain = MBLPhotometerTCS3472Gain1X;
            break;
        case 1:
            photometerTCS3472.gain = MBLPhotometerTCS3472Gain4X;
            break;
        case 2:
            photometerTCS3472.gain = MBLPhotometerTCS3472Gain16X;
            break;
        default:
            photometerTCS3472.gain = MBLPhotometerTCS3472Gain60X;
            break;
    }
    photometerTCS3472.integrationTime = self.photometerTCS3472IntegrationSlider.value;
    photometerTCS3472.ledFlash = self.photometerTCS3472LedFlashSwitch.on;
    
    self.photometerTCS3472Event = [photometerTCS3472.color periodicReadWithPeriod:700];
    [self.streamingEvents addObject:self.photometerTCS3472Event];
    [self.photometerTCS3472Event startNotificationsWithHandlerAsync:^(MBLRGBData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.photometerTCS3472RedColor.text = [NSString stringWithFormat:@"%d", obj.red];
            self.photometerTCS3472GreenColor.text = [NSString stringWithFormat:@"%d", obj.green];
            self.photometerTCS3472BlueColor.text = [NSString stringWithFormat:@"%d", obj.blue];
            self.photometerTCS3472ClearColor.text = [NSString stringWithFormat:@"%d", obj.clear];
        }
    }];
}

- (IBAction)photometerTCS3472StopStreamPressed:(id)sender
{
    [self.photometerTCS3472StartStream setEnabled:YES];
    [self.photometerTCS3472StopStream setEnabled:NO];
    [self.photometerTCS3472Gain setEnabled:YES];
    [self.photometerTCS3472IntegrationSlider setEnabled:YES];
    [self.photometerTCS3472LedFlashSwitch setEnabled:YES];
    
    [self.streamingEvents removeObject:self.photometerTCS3472Event];
    [self.photometerTCS3472Event stopNotificationsAsync];
    self.photometerTCS3472RedColor.text = @"XXXX";
    self.photometerTCS3472GreenColor.text = @"XXXX";
    self.photometerTCS3472BlueColor.text = @"XXXX";
    self.photometerTCS3472ClearColor.text = @"XXXX";
}


- (IBAction)hygrometerBME280StartStreamPressed:(id)sender
{
    [self.hygrometerBME280StartStream setEnabled:NO];
    [self.hygrometerBME280StopStream setEnabled:YES];
    [self.hygrometerBME280Oversample setEnabled:NO];
    
    MBLHygrometerBME280 *hygrometerBME280 = (MBLHygrometerBME280 *)self.device.hygrometer;
    switch (self.hygrometerBME280Oversample.selectedSegmentIndex) {
        case 0:
            hygrometerBME280.humidityOversampling = MBLHygrometerBME280Oversample1X;
            break;
        case 1:
            hygrometerBME280.humidityOversampling = MBLHygrometerBME280Oversample2X;
            break;
        case 2:
            hygrometerBME280.humidityOversampling = MBLHygrometerBME280Oversample4X;
            break;
        case 3:
            hygrometerBME280.humidityOversampling = MBLHygrometerBME280Oversample8X;
            break;
        default:
            hygrometerBME280.humidityOversampling = MBLHygrometerBME280Oversample16X;
            break;
    }
    
    self.hygrometerBME280Event = [self.device.hygrometer.humidity periodicReadWithPeriod:700];
    [self.streamingEvents addObject:self.hygrometerBME280Event];
    [self.hygrometerBME280Event startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.hygrometerBME280Humidity.text = [NSString stringWithFormat:@"%.2f", obj.value.doubleValue];
        }
    }];
}

- (IBAction)hygrometerBME280StopStreamPressed:(id)sender
{
    [self.hygrometerBME280StartStream setEnabled:YES];
    [self.hygrometerBME280StopStream setEnabled:NO];
    [self.hygrometerBME280Oversample setEnabled:YES];
    
    [self.streamingEvents removeObject:self.hygrometerBME280Event];
    [self.hygrometerBME280Event stopNotificationsAsync];
    self.hygrometerBME280Humidity.text = @"XX.XX";
}


- (IBAction)conductanceStartStreamPressed:(id)sender
{
    [self.conductanceStartStream setEnabled:NO];
    [self.conductanceStopStream setEnabled:YES];
    [self.conductanceGain setEnabled:NO];
    [self.conductanceVoltage setEnabled:NO];
    [self.conductanceRange setEnabled:NO];
    [self.conductanceChannelStepper setEnabled:NO];
    
    self.device.conductance.gain = self.conductanceGain.selectedSegmentIndex;
    self.device.conductance.voltage = self.conductanceVoltage.selectedSegmentIndex;
    self.device.conductance.range = self.conductanceRange.selectedSegmentIndex;
    uint8_t channel = round(self.conductanceChannelStepper.value);
    
    [self.device.conductance calibrateAsync];
    self.conductanceEvent = [self.device.conductance.channels[channel] periodicReadWithPeriod:500];
    [self.streamingEvents addObject:self.conductanceEvent];
    [self.conductanceEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        if (obj) {
            self.conductanceLabel.text = [NSString stringWithFormat:@"%d", obj.value.unsignedIntValue];
        }
    }];
}

- (IBAction)conductanceStopStreamPressed:(id)sender
{
    [self.conductanceStartStream setEnabled:YES];
    [self.conductanceStopStream setEnabled:NO];
    [self.conductanceGain setEnabled:YES];
    [self.conductanceVoltage setEnabled:YES];
    [self.conductanceRange setEnabled:YES];
    [self.conductanceChannelStepper setEnabled:YES];
    
    [self.streamingEvents removeObject:self.conductanceEvent];
    [self.conductanceEvent stopNotificationsAsync];
    self.conductanceLabel.text = @"XXXX";
}

- (IBAction)conductanceChannelChanged:(id)sender
{
    self.conductanceChannelLabel.text = [NSString stringWithFormat:@"%d", (int)round(self.conductanceChannelStepper.value)];
}


- (IBAction)i2cReadBytesPressed:(id)sender
{
    uint deviceAddress = 0;
    NSScanner *deviceAddressScanner = [NSScanner scannerWithString:self.i2cDeviceAddress.text];
    if ([deviceAddressScanner scanHexInt:&deviceAddress]) {
        uint registerAddress = 0;
        NSScanner *registerAddressScanner = [NSScanner scannerWithString:self.i2cRegisterAddress.text];
        if ([registerAddressScanner scanHexInt:&registerAddress]) {
            uint8_t length = 1;
            if (self.i2cSizeSelector.selectedSegmentIndex == 1) {
                length = 2;
            } else if (self.i2cSizeSelector.selectedSegmentIndex == 2) {
                length = 4;
            }
            MBLI2CData<MBLDataSample *> *reg = [self.device.serial dataAtDeviceAddress:deviceAddress registerAddress:registerAddress length:length];
            [[reg readAsync] success:^(MBLDataSample * _Nonnull result) {
                self.i2cReadByteLabel.text = result.data.description;
            }];
        } else {
            self.i2cRegisterAddress.text = @"";
        }
    } else {
        self.i2cDeviceAddress.text = @"";
    }
}

- (IBAction)i2cWriteBytesPressed:(id)sender
{
    uint deviceAddress = 0;
    NSScanner *deviceAddressScanner = [NSScanner scannerWithString:self.i2cDeviceAddress.text];
    if ([deviceAddressScanner scanHexInt:&deviceAddress]) {
        uint registerAddress = 0;
        NSScanner *registerAddressScanner = [NSScanner scannerWithString:self.i2cRegisterAddress.text];
        if ([registerAddressScanner scanHexInt:&registerAddress]) {
            uint writeData = 0;
            NSScanner *writeDataScanner = [NSScanner scannerWithString:self.i2cWriteByteField.text];
            if ([writeDataScanner scanHexInt:&writeData]) {
                uint8_t length = 1;
                if (self.i2cSizeSelector.selectedSegmentIndex == 1) {
                    length = 2;
                } else if (self.i2cSizeSelector.selectedSegmentIndex == 2) {
                    length = 4;
                }
                MBLI2CData<MBLDataSample *> *reg = [self.device.serial dataAtDeviceAddress:deviceAddress registerAddress:registerAddress length:length];
                [reg writeDataAsync:[NSData dataWithBytes:&writeData length:length]];
            }
            self.i2cWriteByteField.text = @"";
        } else {
            self.i2cRegisterAddress.text = @"";
        }
    } else {
        self.i2cDeviceAddress.text = @"";
    }
}


- (IBAction)neopixelLengthChanged:(id)sender
{
    self.neopixelLengthLabel.text = [NSString stringWithFormat:@"%d", (int)round(self.neopixelLengthStepper.value)];
}

- (BFTask *)neopixelInitStrand
{
    if (!self.neopixelStrand) {
        self.neopixelStrand = [self.device.neopixel strandWithColor:self.neopixelColor.selectedSegmentIndex
                                                              speed:self.neopixelSpeed.selectedSegmentIndex
                                                                pin:self.neopixelPin.selectedSegmentIndex
                                                             length:(uint8_t)round(self.neopixelLengthStepper.value)];
        
        self.neopixelStrandInitTask = [self.neopixelStrand initializeAsync];
        
        self.neopixelColor.enabled = NO;
        self.neopixelSpeed.enabled = NO;
        self.neopixelPin.enabled = NO;
        self.neopixelLengthStepper.enabled = NO;
    }
    return self.neopixelStrandInitTask;
}

- (void)neopixelSetColor:(UIColor *)color
{
    const int max = round(self.neopixelLengthStepper.value);
    for (int i = 0; i < max; i++) {
        [self.neopixelStrand setPixelAsync:i color:color];
    }
}

- (IBAction)neopixelSetRedPressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self neopixelSetColor:[UIColor redColor]];
    }];
}

- (IBAction)neopixelSetGreenPressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self neopixelSetColor:[UIColor greenColor]];
    }];
}

- (IBAction)neopixelSetBluePressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self neopixelSetColor:[UIColor blueColor]];
    }];
}

- (IBAction)neopixelSetRainbowPressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self.neopixelStrand setRainbowWithHoldAsync:NO];
    }];
}

- (IBAction)neopixelRotateLeftPressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self.neopixelStrand rotateStrandWithDirectionAsync:MBLRotationDirectionTowardsBoard repetitions:0xFF period:100];
    }];
}

- (IBAction)neopixelRotateRightPressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self.neopixelStrand rotateStrandWithDirectionAsync:MBLRotationDirectionAwayFromBoard repetitions:0xFF period:100];
    }];
}

- (IBAction)neopixelTurnOffPressed:(id)sender
{
    [[self neopixelInitStrand] success:^(id  _Nonnull result) {
        [self.neopixelStrand clearAllPixelsAsync];
    }];
    
    self.neopixelSetRed.enabled = NO;
    self.neopixelSetGreen.enabled = NO;
    self.neopixelSetBlue.enabled = NO;
    self.neopixelSetRainbow.enabled = NO;
    self.neopixelRotateRight.enabled = NO;
    self.neopixelRotateLeft.enabled = NO;
    self.neopixelTurnOff.enabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.neopixelStrand deinitializeAsync];
        self.neopixelStrand = nil;
        
        self.neopixelColor.enabled = YES;
        self.neopixelSpeed.enabled = YES;
        self.neopixelPin.enabled = YES;
        self.neopixelLengthStepper.enabled = YES;
        
        self.neopixelSetRed.enabled = YES;
        self.neopixelSetGreen.enabled = YES;
        self.neopixelSetBlue.enabled = YES;
        self.neopixelSetRainbow.enabled = YES;
        self.neopixelRotateRight.enabled = YES;
        self.neopixelRotateLeft.enabled = YES;
        self.neopixelTurnOff.enabled = YES;
    });
}

#pragma mark - DFU Service delegate methods

- (void)didStateChangedTo:(enum State)state
{
    if (state == StateCompleted) {
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"Success!";
        [self.hud hideAnimated:YES afterDelay:2.0];
    }
}

- (void)didErrorOccur:(enum DFUError)error withMessage:(NSString *)message
{
    NSLog(@"Firmware update error %ld: %@", (long) error, message);
    [[[UIAlertView alloc] initWithTitle:@"Update Error"
                                message:[@"Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: " stringByAppendingString:message]
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
    [self.hud hideAnimated:YES];
}

- (void)onUploadProgress:(NSInteger)part
              totalParts:(NSInteger)totalParts
                progress:(NSInteger)percentage
currentSpeedBytesPerSecond:(double)speed
  avgSpeedBytesPerSecond:(double)avgSpeed
{
    self.hud.progress = (double)percentage / 100.0;
}

- (void)logWith:(enum LogLevel)level message:(NSString *)message
{
    if (level >= LogLevelApplication) {
        NSLog(@"%d: %@", (int)level, message);
    }
}

#pragma mark - DFUPeripheralSelector

- (BOOL)select:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    return [peripheral.identifier isEqual:self.device.identifier];
}

- (NSArray<CBUUID *> *)filterBy
{
    return nil;
}

@end
