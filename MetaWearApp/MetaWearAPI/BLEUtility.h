//
//  BLEUtility.h
//
//  Created by Ole Andreas Torvmark on 9/22/12.
//  Copyright (c) 2012 Texas Instruments. All rights reserved.
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
#import <CoreBluetooth/CoreBluetooth.h>

#define MW_BASE_LONG_UUID @"326A0000-85CB-9195-D9DD-464CFBBAE75A"

/// Class for BLEUtility Functions
@interface BLEUtility : NSObject

/**
 Read A specific Characteristic value
 Will trigger a BLE callback
 @param CBPeripheral to write to, NSString of the service UUID, NSString of the characteristic UUID
 @returns none
 */
+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID;

/**
 Read A specific Characteristic value
 Will trigger a BLE callback
 @param CBPeripheral to write to, CBUUID of the service UUID, CBUUID of the characteristic UUID
 @returns none
 */
+(void)readCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID;

/**
 Set the nofication state for a specific Characteristic
 Will trigger a BLE callback
 @param CBPeripheral to write to, NSString of the service UUID, NSString of the characteristic UUID, BOOL for the notification setting (1: notify, 0: stop notify)
 @returns none
 */
+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;

/**
 Check if specific Characteristic is notifiable
 @param CBPeripheral to write to, CBUUID of the service UUID, CBUUID of the characteristic UUID, BOOL for the notification setting (1: notify, 0: stop notify)
 @returns none
 */
+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID enable:(BOOL)enable;

/**
 Write data/value to a specific Characteristic
 Will trigger a BLE callback
 @param CBPeripheral to write to, NSString of the service UUID, NSString of the characteristic UUID, NSData of the data/value
 @returns none
 */
+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

/**
 Write data/value to a specific Characteristic
 Will trigger a BLE callback
 @param CBPeripheral to write to, CBUUID of the service UUID, CBUUID of the characteristic UUID, NSData of the data/value
 @returns none
 */
+(void)writeCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data;

/**
 Write data/value to a specific Characteristic with no response
 Will trigger a BLE callback
 @param CBPeripheral to write to, NSString of the service UUID, NSString of the characteristic UUID, NSData of the data/value
 @returns none
 */
+(void)writeNoResponseCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

/**
 Write data/value to a specific Characteristic with no response
 Will trigger a BLE callback
 @param CBPeripheral to write to, CBUUID of the service UUID, CBUUID of the characteristic UUID, NSData of the data/value
 @returns none
 */
+(void)writeNoResponseCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data;

/**
 Check if specific Characteristic is notifiable
 @param CBPeripheral to write to, CBUUID of the service UUID, CBUUID of the characteristic UUID
 @returns bool (1: notificable, 0: not notifiable)
 */
+(bool) isCharacteristicNotifiable:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *) cCBUUID;

/**
 Function to expand a 16-bit UUID to 128-bit UUID
 Will trigger a BLE callback
 @param short CBUUID
 @returns long CBUUID
 */
+(CBUUID *) expandToTIUUID:(CBUUID *)sourceUUID;

/**
 Function to convert an CBUUID to NSString
 Will trigger a BLE callback
 @param short CBUUID
 @returns long CBUUID
 */
+(NSString *) CBUUIDToString:(CBUUID *)inUUID;

@end
