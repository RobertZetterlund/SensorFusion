//
//  StartViewController.m
//  MetaWearApiTest
//
//  Created by Yu Suo on 8/11/14.
//  Copyright (c) 2014 MbientLab. All rights reserved.
//

#import "StartViewController.h"

@implementation StartViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
