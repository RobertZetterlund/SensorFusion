//
//  DfuViewController.h
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/9/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFUController.h"
#import "MetaWearAPI.h"
#import "MetaWearDelegate.h"

@interface DfuViewController : UIViewController <DFUControllerDelegate, MetaWearDelegate>

@property (strong, nonatomic) MetaWearAPI *metawearAPI;

@property DFUController *dfuController;

@property (strong, nonatomic) UIProgressView *progressView;

@property BOOL isTransferring;

@property (strong, nonatomic) UILabel *appNameLabel;
@property (strong, nonatomic) UILabel *appSizeLabel;
@property (strong, nonatomic) UILabel *targetNameLabel;
@property (strong, nonatomic) UILabel *targetStatusLabel;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIButton *uploadButton;

@end
