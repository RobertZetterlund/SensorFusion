//
//  DFUUploadViewController.m
//  MetaWearApp
//
//  Created by Laura Kassovic on 7/15/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import "DFUUploadViewController.h"

@implementation DFUUploadViewController

@synthesize appSizeLabel, appNameLabel, targetStatusLabel, targetNameLabel, progressLabel, uploadButton, progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"DFU";
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGRect navBarFrame = CGRectMake(0, 20, self.view.frame.size.width, 44.0);
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:navBarFrame];
        navBar.backgroundColor = [UIColor whiteColor];
        navBar.barTintColor = [UIColor whiteColor];
        UINavigationItem *navItem = [UINavigationItem alloc];
        navItem.title = @"DFU";
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar pushNavigationItem:navItem animated:false];
        [self.view addSubview:navBar];
        
        self.appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, 100, 20)];
        self.appNameLabel.text = @"";
        [self.view addSubview:self.appNameLabel];
        
        self.appSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 90, 100, 20)];
        self.appSizeLabel.text = @"";
        [self.view addSubview:self.appSizeLabel];
        
        self.targetNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 100, 20)];
        self.targetNameLabel.text = @"";
        [self.view addSubview:self.targetNameLabel];
        
        self.targetStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 120, 100, 20)];
        self.targetStatusLabel.text = @"";
        [self.view addSubview:self.targetStatusLabel];
        
        self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 100, 20)];
        self.progressLabel.text = @"";
        [self.view addSubview:self.progressLabel];
        
        self.uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.uploadButton.frame = CGRectMake(20, 300, 280, 30.0);
        [self.uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
        [self.uploadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.uploadButton addTarget:self action:@selector(uploadButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.uploadButton];
        
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 250, 240, 100)];
        self.progressView.progress = 0;
        [self.view addSubview:self.progressView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadButtonPressed
{
    if (!self.isTransferring) {
        self.isTransferring = YES;
        [self.dfuController startTransfer];
        [self.uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
    } else {
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
    if (state == IDLE) {
        self.uploadButton.enabled = YES;
    }
    self.targetStatusLabel.text = [self.dfuController stringFromState:state];
}

@end