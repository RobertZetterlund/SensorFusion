/**
 * DevicesTableViewController.m
 * MetaWearApiTest
 *
 * Created by Stephen Schiffli on 7/29/14.
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

#import "DevicesTableViewController.h"
#import "DeviceDetailViewController.h"
#import "MBProgressHUD.h"
#import <MetaWear/MetaWear.h>
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface DevicesTableViewController () <DFUPeripheralSelector, LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>
@property (nonatomic) NSArray *devices;
@property (nonatomic) UIActivityIndicatorView *activity;
@property (nonatomic) MBProgressHUD *hud;
@property (nonatomic) MBLMetaWear *selected;

@property (weak, nonatomic) IBOutlet UISwitch *scanningSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *metaBootSwitch;
@end

@implementation DevicesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.center = CGPointMake(95, 138);
    [self.tableView addSubview:self.activity];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setScanning:self.scanningSwitch.on];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self setScanning:NO];
}

- (void)setScanning:(BOOL)on
{
    if (on) {
        [self.activity startAnimating];
        if (self.metaBootSwitch.on) {
            [[MBLMetaWearManager sharedManager] startScanForMetaBootsAllowDuplicates:YES handler:^(NSArray *array) {
                self.devices = array;
                [self.tableView reloadData];
            }];
        } else {
            [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:YES handler:^(NSArray *array) {
                self.devices = array;
                [self.tableView reloadData];
            }];
        }
    } else {
        [self.activity stopAnimating];
        [[MBLMetaWearManager sharedManager] stopScan];
    }
}

- (IBAction)scanningSwitchPressed:(UISwitch *)sender
{
    [self setScanning:sender.on];
}

- (IBAction)metaBootSwitchPressed:(id)sender
{
    [[MBLMetaWearManager sharedManager] stopScan];
    // Wait a split second for any final callbacks to fire before starting up scanning again
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.devices = nil;
        [self.tableView reloadData];
        [self setScanning:self.scanningSwitch.on];
    });
}

- (IBAction)clearListPressed:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    MBLMetaWear *cur = self.devices[indexPath.row];
    
    UILabel *uuid = (UILabel *)[cell viewWithTag:1];
    uuid.text = cur.identifier.UUIDString;
    
    UILabel *rssi = (UILabel *)[cell viewWithTag:2];
    rssi.text = [cur.discoveryTimeRSSI stringValue];
    
    UILabel *connected = (UILabel *)[cell viewWithTag:3];
    if (cur.state == CBPeripheralStateConnected) {
        [connected setHidden:NO];
    } else {
        [connected setHidden:YES];
    }
    
    UILabel *name = (UILabel *)[cell viewWithTag:4];
    name.text = cur.name;
    
    UIImageView *signal = (UIImageView *)[cell viewWithTag:5];
    if (cur.averageRSSI) {
        double movingAverage = cur.averageRSSI.doubleValue;
        if (movingAverage < -80.0) {
            signal.image = [UIImage imageNamed:@"wifi_d1"];
        } else if (movingAverage < -70.0) {
            signal.image = [UIImage imageNamed:@"wifi_d2"];
        } else if (movingAverage < -60.0) {
            signal.image = [UIImage imageNamed:@"wifi_d3"];
        } else if (movingAverage < -50.0) {
            signal.image = [UIImage imageNamed:@"wifi_d4"];
        } else if (movingAverage < -40.0) {
            signal.image = [UIImage imageNamed:@"wifi_d5"];
        } else {
            signal.image = [UIImage imageNamed:@"wifi_d6"];
        }
    } else {
        signal.image = [UIImage imageNamed:@"wifi_not_connected"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    self.selected = self.devices[indexPath.row];
    if (self.metaBootSwitch.on) {
        [self.scanningSwitch setOn:NO animated:YES];
        [self.metaBootSwitch setOn:NO animated:YES];
        [self metaBootSwitchPressed:self.metaBootSwitch];
        // Pause the screen while update is going on
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        self.hud.label.text = @"Updating...";
        [[[self.selected prepareForFirmwareUpdateAsync] success:^(MBLFirmwareUpdateInfo * _Nonnull result) {
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
    } else {
        [self performSegueWithIdentifier:@"DeviceDetails" sender:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Devices";
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DeviceDetailViewController *destination = segue.destinationViewController;
    destination.device = self.selected;
}

#pragma mark - DFU Service delegate methods

- (void)didStateChangedTo:(enum State)state
{
    if (state == StateCompleted) {
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = @"Success!";
        [self.hud hideAnimated:YES afterDelay:2.0];
        [[MBLMetaWearManager sharedManager] clearDiscoveredDevices];
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
    return [peripheral.identifier isEqual:self.selected.identifier];
}

- (NSArray<CBUUID *> *)filterBy
{
    return nil;
}

@end
