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

@property (nonatomic, strong) NSArray *devices;
@property (strong, nonatomic) UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UISwitch *scanningSwitch;

@end

@implementation DevicesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.center = CGPointMake(95, 90);
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
        [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:YES handler:^(NSArray *array) {
            self.devices = array;
            [self.tableView reloadData];
        }];
    } else {
        [self.activity stopAnimating];
        [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DeviceDetailViewController *destination = segue.destinationViewController;
    destination.device = sender;
}

@end
