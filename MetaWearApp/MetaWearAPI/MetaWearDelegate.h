//
//  MetaWearDelegate.h
//  MetaWearAPI
//
//  Created by Laura Kassovic on 5/21/14.
//  Copyright (c) 2014 MbientLab Inc. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "Sensors.h"

/// MetaWearDelegate from MetaWearAPI Callbacks
@protocol MetaWearDelegate <NSObject>

@optional

/**
 Callback from startScan()
 @param NSMutableArray metawear Array of devices
 @returns none
*/
- (void) devicesFound: (NSMutableArray *)metawear;

/**
 Callback anytime the connection drops or device fails to connect
 @param NSError error type
 @param CBPeripheral device we failed to connect to 
 @returns none
 */
- (void) connectionFailed: (NSError *)error ForDevice: (CBPeripheral *)device;

/**
 Callback anytime the connection succeeds and the board connects
 @param CBPeripheral device we connected to
 @returns none
 */
- (void) connectionSuccessForDevice: (CBPeripheral *)device;

/**
 Callback anytime the connection drops or device fails to connect
 @param NSError error type
 @param CBPeripheral device we failed to connect to
 @returns none
 */
- (void) disconnectionFailed: (NSError *)error ForDevice: (CBPeripheral *)device;

/**
 Callback anytime the connection succeeds and the board connects
 @param CBPeripheral device we connected to
 @returns none
 */
- (void) disconnectionSuccessForDevice: (CBPeripheral *)device;

/**
 Callback anytime an RSSI read fails
 @param NSError error type
 @returns none
 */
- (void) RSSIReadFail: (NSError *)error;
/**
 Callback anytime an RSSI read succeeds
 @param none
 @returns none
 */
- (void) RSSIReadSuccess: (NSNumber *)rssi;

/**
 Callback anytime a write fails
 @param NSError error type
 @param NSString for transaction type (i.e LED)
 @returns none
 */
- (void) writeFailed: (NSError *)error ForType: (NSString *)type;
/**
 Callback anytime a write succeeds
 @param NSString for transaction type (i.e LED)
 @returns none
 */
- (void) writeSuccessForType: (NSString *)type;

/**
 Callback anytime a read fails
 @param NSError error type
 @param NSString for transaction type (i.e LED)
 @returns none
 */
- (void) readFailed: (NSError *)error ForType: (NSString *)type;
/**
 Callback anytime a read succeeds
 @param NSString for transaction type (i.e LED)
 @returns none
 */
- (void) readSuccessForType: (NSString *)type;

/**
 Callback anytime a switch state request fails
 @param Switch button state data
 @returns none
 */
- (void) retrieveSwitchValueFailed: (NSError *)error;
/**
 Callback anytime a switch state is requested
 @param NSError error type
 @returns none
 */
- (void) retrieveSwitchValueSuccess: (Switch *)data;

/**
 Callback anytime an LED state request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveLEDDataFailed: (NSError *)error;
/**
 Callback anytime an LED state is requested
 @param Led state data
 @returns none
 */
- (void) retrieveLEDDataSuccess: (Led *)data;

/**
 Callback anytime an accelerometer state request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveAccelerometerDataFailed: (NSError *)error;
/**
 Callback anytime an accelerometer state is requested
 @param Accelerometer state data
 @returns none
 */
- (void) retrieveAccelerometerDataSuccess: (Accelerometer *)data;

/**
 Callback anytime a temperature state request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveTemperatureFailed: (NSError *)error;
/**
 Callback anytime a temperature state is requested
 @param Temperature state data
 @returns none
 */
- (void) retrieveTemperatureSuccess: (Temperature *)data;

/**
 Callback anytime a GPIO value request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveGPIOValueFailed: (NSError *)error;
/**
 Callback anytime a GPIO value is requested
 @param Battery state data
 @returns none
 */
- (void) retrieveGPIOValueSuccess: (GPIO *)data;

/**
 Callback anytime a GPIO command request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveGPIOCommandFailed: (NSError *)error;
/**
 Callback anytime a GPIO command is requested
 @param Battery state data
 @returns none
 */
- (void) retrieveGPIOCommandSuccess: (GPIO *)data;

/**
 Callback anytime a Battery state request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveBatteryInfoFailed: (NSError *)error;
/**
 Callback anytime a Battery state is requested
 @param Battery state data
 @returns none
 */
- (void) retrieveBatteryInfoSuccess: (Battery *)data;

/**
 Callback anytime a Device info request fails
 @param NSError error type
 @returns none
 */
- (void) retrieveDeviceInfoFailed: (NSError *)error;
/**
 Callback anytime Device info is requested
 @param Battery state data
 @returns none
 */
- (void) retrieveDeviceInfoSuccess: (DeviceInfo *)data;

@end

