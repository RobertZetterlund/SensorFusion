//
//  DfuViewController.m
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/9/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import "DfuViewController.h"
#import "AppInfoCell.h"
#import "DeviceInformationCell.h"
#import "AppDelegate.h"

@implementation DfuViewController

@synthesize dfuController, progressView, isTransferring, appSizeLabel, appNameLabel, targetStatusLabel, targetNameLabel, progressLabel, uploadButton, metawearAPI;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.title = @"DFU";
        
        self.dfuController = [[DFUController alloc] init];
        
        self.appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, 170, 21)];
        self.appSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, 151, 21)];
        self.targetNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, 145, 21)];
        self.targetStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 60, 151, 21)];
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 54, 60, 21)];
        
        self.uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 79, 120, 30)];
        self.uploadButton.titleLabel.text = @"Upload";
        [self.uploadButton addTarget:self action:@selector(uploadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.frame = CGRectMake(20, 44, 240, 2);
        [self.view addSubview:self.progressView];
        
        NSURL *firmwareURL = [[NSBundle mainBundle] URLForResource:@"emetawear" withExtension:@"bin"];
        [self.dfuController setFirmwareURL:firmwareURL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.metawearAPI = [[MetaWearAPI alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.metawearAPI = appDelegate.metawearAPI;
    self.metawearAPI.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.dfuController.delegate = self;
    
    self.appNameLabel.text = self.dfuController.appName;
    self.appSizeLabel.text = [NSString stringWithFormat:@"%d bytes", self.dfuController.appSize];
    
    self.targetNameLabel.text = self.dfuController.targetName;
    self.targetStatusLabel.text = @"-";
    
    self.uploadButton.enabled = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.dfuController cancelTransfer];
    self.isTransferring = NO;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) uploadButtonPressed
{
    [self.metawearAPI jumpToBootloader];
    
    if (!self.isTransferring)
    {
        self.isTransferring = YES;
        [self.dfuController startTransfer];
        [self.uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    else
    {
        self.isTransferring = NO;
        [self.dfuController cancelTransfer];
        [self.uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    }
}

- (void) didUpdateProgress:(float) progress
{
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f %%", progress*100];
    [self.progressView setProgress:progress animated:YES];
}

- (void) didFinishTransfer
{
    NSString *message = [NSString stringWithFormat:@"The upload completed successfully, %@ has been reset and now runs %@.", self.dfuController.targetName, self.dfuController.appName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Finished upload!" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) didCancelTransfer
{
    NSString *message = [NSString stringWithFormat:@"The upload was cancelled. %@ has been reset, and runs its original application.", self.dfuController.targetName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Canceled upload" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) didDisconnect:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"The connection was lost, with error description: %@", error.description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection lost" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) didChangeState:(DFUControllerState)state
{
    if (state == IDLE)
    {
        self.uploadButton.enabled = YES;
    }
    self.targetStatusLabel.text = [self.dfuController stringFromState:state];
}

@end
