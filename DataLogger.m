//
//  DataLogger.m
//  MetaWearApp
//
//  Created by Yu Suo on 7/22/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.

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
#import "DataLogger.h"
#import <CoreMotion/CoreMotion.h>

@interface DataLogger (hidden)


/**
 * processAccel:withError:
 *
 * Appends the new raw accleration data to the appropriate instance variable string.
 */

/**
 * processGyro:withError:
 *
 * Appends the new raw gyro data to the appropriate instance variable string.
 */

/**
 * writeDataToDisk
 *
 * Using the boolean instance variables to know which strings to write, this method saves
 * the data strings to the app's documents directory. The filename of each string contains
 * a date and time string so that a user can save multiple log runs. The time format needs
 * to be long so that a user can log two different runs that start in the same minute.
*/

@end


@implementation DataLogger
- (id)init
{
    
    self = [super init];
    if (self) {

        // Limiting the concurrent ops to 1 is a cheap way to avoid two handlers editing the same
        // string at the same time.
        _accelQueue = [[NSOperationQueue alloc] init];
        [_accelQueue setMaxConcurrentOperationCount:1];
        
        // Initially logging is not turned on.
        _logUserAccelerationData = false;
        _logRawAccelerometerData = false;
        
        _userAccelerationString = [[NSString alloc] init];
        _rawAccelerometerString = [[NSString alloc] init];
        
    }
    
    return self;
}

- (void) startLoggingMotionData {
    
    NSLog(@"Starting to log motion data.");
    
    CMAccelerometerHandler accelHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self processAccel:accelerometerData withError:error];
    };
    
    
    /*if (_logRawAccelerometerData) {
        [_motionManager startAccelerometerUpdatesToQueue:_accelQueue withHandler:accelHandler];
    }*/
    
}

- (void) stopLoggingMotionDataAndSave {
    
    NSLog(@"Stopping data logging.");
    
    /*[_motionManager stopDeviceMotionUpdates];
    [_deviceMotionQueue waitUntilAllOperationsAreFinished];
    
    [_motionManager stopAccelerometerUpdates];
    [_accelQueue waitUntilAllOperationsAreFinished];
    
    [_motionManager stopGyroUpdates];
    [_gyroQueue waitUntilAllOperationsAreFinished];*/
    
    // Save all of the data!
    [self writeDataToDisk];
    
}

- (void) processAccel:(CMAccelerometerData*)accelData withError:(NSError*)error {
    
    if (_logRawAccelerometerData) {
        _rawAccelerometerString = [_rawAccelerometerString stringByAppendingFormat:@"%f,%f,%f,%f\n", accelData.timestamp,
                                   accelData.acceleration.x,
                                   accelData.acceleration.y,
                                   accelData.acceleration.z,
                                   nil];
    }
}


/**
 * processMotion:withError:
 *
 * Appends the new motion data to the appropriate instance variable strings.
 */
- (void) processMotion:(CMDeviceMotion*)motion withError:(NSError*)error {
    
    //    NSLog(@"Processing motion with motion pointer %p",motion);
    //    NSLog(@"Curr accel string %@",_userAccelerationString);
    
    if (_logUserAccelerationData) {
        _userAccelerationString = [_userAccelerationString stringByAppendingFormat:@"%f,%f,%f,%f\n", motion.timestamp,
                                   motion.userAcceleration.x,
                                   motion.userAcceleration.y,
                                   motion.userAcceleration.z,
                                   nil];
    }
    
}


- (void) setLogUserAccelerationData:(bool)newValue {
    _logUserAccelerationData = newValue;
}

- (void) setLogRawAccelerometerData:(bool)newValue {
    _logRawAccelerometerData = newValue;
}


- (void) writeDataToDisk {
    NSLog(@"Saving everything to disk!");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    // Some filesystems hate colons
    NSString *dateString = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    // I hate spaces
    dateString = [dateString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // Nobody can stand forward slashes
    dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    
    if (_logUserAccelerationData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userAcceleration_%@.txt", dateString, nil]];
        
        [_userAccelerationString writeToFile:fullPath
                                  atomically:NO
                                    encoding:NSStringEncodingConversionAllowLossy
                                       error:nil];
        _userAccelerationString = @"";
    }
    
    if (_logRawAccelerometerData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"rawAccelerometer_%@.txt", dateString, nil]];
        
        [_rawAccelerometerString writeToFile:fullPath
                                  atomically:NO
                                    encoding:NSStringEncodingConversionAllowLossy
                                       error:nil];
        _rawAccelerometerString = @"";
    }
    
}



@end
