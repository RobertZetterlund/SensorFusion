//
//  DFUBootViewController.h
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/15/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFUController.h"
#import "MetaWearAPI.h"
#import "MetaWearDelegate.h"

@interface DFUBootViewController : UIViewController <CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate, MetaWearDelegate>

@property (strong, nonatomic) MetaWearAPI *metawearAPI;
@property DFUController *dfuController;

@property (strong, nonatomic) UIActivityIndicatorView *scanActivityIndicator;
@property (strong, nonatomic) UITableView *targetTableView;
@property (strong, nonatomic) UIView *scanButton;

@property CBCentralManager *cm;
@property (strong, nonatomic) UILabel *appNameLabel;
@property (strong, nonatomic) UILabel *appSizeLabel;
@property NSMutableArray *discoveredTargets;
@property NSMutableDictionary *discoveredTargetsRSSI;

@property BOOL isScanning;

- (void)scanButtonPressed;

@end
