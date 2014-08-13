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

@end

@implementation DevicesTableViewController

UILabel *messageLabel;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    MBLMetaWearManager *manager = [MBLMetaWearManager sharedManager];
    [manager startScanForMetaWearsWithHandler:^(NSArray *array) {
        self.devices = [array mutableCopy];
        [self.devices sortUsingComparator:^NSComparisonResult(MBLMetaWear *dev1, MBLMetaWear *dev2) {
            return [dev1.peripheral.RSSI compare:dev2.peripheral.RSSI];
        }];
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
    [self.devices removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)scanningSwitchPressed:(UISwitch *)sender
{
    if (sender.on) {
        NSLog(@"ON");
    } else {
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.devices.count) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [messageLabel setHidden:TRUE];
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        [messageLabel setHidden:FALSE];
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No MetaWears found...";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
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
