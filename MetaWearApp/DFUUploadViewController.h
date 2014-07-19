//
//  DFUUploadViewController.h
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/15/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFUController.h"

@interface DFUUploadViewController : UIViewController <DFUControllerDelegate>
@property (strong, nonatomic) UIProgressView *progressView;

@property DFUController *dfuController;

@property (strong, nonatomic) UILabel *appNameLabel;
@property (strong, nonatomic) UILabel *appSizeLabel;
@property (strong, nonatomic) UILabel *targetNameLabel;
@property (strong, nonatomic) UILabel *targetStatusLabel;
@property (strong, nonatomic) UILabel *progressLabel;

@property (strong, nonatomic) UIButton *uploadButton;

@property BOOL isTransferring;

@end
