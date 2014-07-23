//
//  AccelerometerViewController.h
//  MetaWearAPI
//
//  Created by Laura Kassovic on 6/4/14.
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

#import <UIKit/UIKit.h>
#import "MetaWearAPI.h"
#import "MetaWearDelegate.h"
#import "GraphView.h"
#import "AccelerometerFilter.h"

#define kUpdateFrequency	60.0
#define kLocalizedStop		NSLocalizedString(@"Stop Recording","stop taking samples")
#define kLocalizedStart	NSLocalizedString(@"Start Recording","start taking samples")

@interface AccelerometerViewController : UIViewController <MetaWearDelegate>
{
	AccelerometerFilter *filter;
	BOOL isRecording, useAdaptive;
    NSMutableArray *accDataArray;
    NSDate *dataStartTime;
}

@property (nonatomic, strong) UILabel *unfilteredLabel;
@property (nonatomic, strong) UILabel *filteredLabel;

@property (nonatomic, strong) GraphView *unfiltered;
@property (nonatomic, strong) GraphView *filtered;

@property (nonatomic, strong) UIButton *recordData;
@property (nonatomic, strong) UIButton *sendData;


@property (nonatomic, strong) UISegmentedControl *filterC;
@property (nonatomic, strong) UISegmentedControl *filterTypeC;

@property (strong, nonatomic) MetaWearAPI *metawearAPI;

- (void)pauseOrResume:(id)sender;
- (void)filterSelect:(id)sender;
- (void)adaptiveSelect:(id)sender;
- (NSString *)processAccData:(id)sender;

// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
- (void)changeFilter:(Class)filterClass;

@end
