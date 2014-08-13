//
//  DeviceDetailViewController.h
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 7/30/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MetaWear/MetaWear.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DeviceDetailViewController : UIViewController

@property (strong, nonatomic) MBLMetaWear *device;

@end
