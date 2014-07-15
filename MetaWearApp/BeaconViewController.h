//
//  BeaconViewController.h
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/15/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetaWearAPI.h"
#import "MetaWearDelegate.h"

@interface BeaconViewController : UIViewController  <MetaWearDelegate>

@property (nonatomic, retain) UIButton *turnOnButton;
@property (nonatomic, retain) UIButton *turnOffButton;

@property (strong, nonatomic) MetaWearAPI *metawearAPI;

@end
