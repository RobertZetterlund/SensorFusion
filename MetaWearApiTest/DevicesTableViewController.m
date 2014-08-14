//
//  DevicesTableViewController.m
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 7/29/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DeviceDetailViewController.h"
#import <MetaWear/MetaWear.h>

@interface DevicesTableViewController ()

@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic) BOOL isScanning;

@end

@implementation DevicesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setScanning:YES];
}

- (void)setScanning:(BOOL)on
{
    self.isScanning = on;
    if (on) {
        [[MBLMetaWearManager sharedManager] startScanForMetaWearsWithHandler:^(NSArray *array) {
            self.devices = [array mutableCopy];
            [self.devices sortUsingComparator:^NSComparisonResult(MBLMetaWear *dev1, MBLMetaWear *dev2) {
                return [dev1.peripheral.RSSI compare:dev2.peripheral.RSSI];
            }];
            [self.tableView reloadData];
        }];
    } else {
        [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
        [self.tableView reloadData];
    }
}

- (IBAction)scanningSwitchPressed:(UISwitch *)sender
{
    [self setScanning:sender.on];
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
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    name.text = cur.peripheral.name;
    
    UILabel *uuid = (UILabel *)[cell viewWithTag:2];
    uuid.text = cur.peripheral.identifier.UUIDString;
    
    UILabel *rssi = (UILabel *)[cell viewWithTag:3];
    rssi.text = [cur.discoveryTimeRSSI stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MBLMetaWear *selected = self.devices[indexPath.row];
    [self performSegueWithIdentifier:@"DeviceDetails" sender:selected];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Devices";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (self.isScanning) {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.center = CGPointMake(95, 40);
        [activity startAnimating];
        [view addSubview:activity];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DeviceDetailViewController *destination = segue.destinationViewController;
    destination.device = sender;
}

@end
