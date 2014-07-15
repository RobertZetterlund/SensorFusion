//
//  RootTableViewController.m
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/9/14.
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

#import "RootTableViewController.h"
#import "MetaWearViewController.h"
#import "FinderViewController.h"
#import "LedViewController.h"
#import "AccelerometerViewController.h"
#import "StatusViewController.h"
#import "DfuViewController.h"
#import "BeaconViewController.h"

@implementation RootTableViewController

@synthesize metaWearViewController, finderViewController, ledViewController, accelerometerViewController, statusViewController, dfuViewController, beaconViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"MetaWear Device Menu";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Connect Mode";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Finder Mode";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"LED Mode";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Accelerometer Mode";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"General Mode";
    } else if (indexPath.row == 5) {
        cell.textLabel.text = @"iBeacon Mode";
    } //else if (indexPath.row == 6) {
        //cell.textLabel.text = @"DFU (OAD Updates) Mode";
    //}
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	NSUInteger row = indexPath.row;
	
    if (row == 0) {
        self.metaWearViewController = [[MetaWearViewController alloc] initWithNibName:nil bundle:nil];
        [[self navigationController] pushViewController:self.metaWearViewController animated:YES];
    }
    if (row == 1) {
        self.finderViewController = [[FinderViewController alloc] initWithNibName:nil bundle:nil];
        [[self navigationController] pushViewController:self.finderViewController animated:YES];
    }
    if (row == 2) {
        self.ledViewController = [[LedViewController alloc] initWithNibName:nil bundle:nil];
        [[self navigationController] pushViewController:self.ledViewController animated:YES];
    }
    if (row == 3) {
        self.accelerometerViewController = [[AccelerometerViewController alloc] initWithNibName:nil bundle:nil];
        [[self navigationController] pushViewController:self.accelerometerViewController animated:YES];
    }
    if (row == 4) {
        self.statusViewController = [[StatusViewController alloc] initWithNibName:nil bundle:nil];
        [[self navigationController] pushViewController:self.statusViewController animated:YES];
    }
    if (row == 5) {
        self.beaconViewController = [[BeaconViewController alloc] initWithNibName:nil bundle:nil];
        [[self navigationController] pushViewController:self.beaconViewController animated:YES];
    }
    if (row == 6) {
        //self.dfuViewController = [[DfuViewController alloc] initWithNibName:nil bundle:nil];
        //[[self navigationController] pushViewController:self.dfuViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

@end