/**
 * MBLMetaWear.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/29/14.
 * Copyright 2014 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms . The License limits your use, and you acknowledge,
 * that the  Software may not be modified, copied or distributed and can be used
 * solely and exclusively in conjunction with a MbientLab Inc, product.  Other
 * than for the foregoing purpose, you may not use, reproduce, copy, prepare
 * derivative works of, modify, distribute, perform, display or sell this
 * Software and/or its documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab Inc, at www.mbientlab.com.
 */

#import <CoreBluetooth/CoreBluetooth.h>
#import <MetaWear/MBLConstants.h>

@class MBLTemperature;
@class MBLAccelerometer;
@class MBLLED;
@class MBLMechanicalSwitch;
@class MBLGPIO;
@class MBLHapticBuzzer;
@class MBLiBeacon;
@class MBLNeopixel;

@interface MBLMetaWear : NSObject <CBPeripheralDelegate>

/**
 List of all MetaWear modules avaliable for use
 */
@property (nonatomic, strong, readonly) MBLMechanicalSwitch *mechanicalSwitch;
@property (nonatomic, strong, readonly) MBLLED *led;
@property (nonatomic, strong, readonly) MBLTemperature *temperature;
@property (nonatomic, strong, readonly) MBLAccelerometer *accelerometer;
@property (nonatomic, strong, readonly) MBLGPIO *gpio;
@property (nonatomic, strong, readonly) MBLHapticBuzzer *hapticBuzzer;
@property (nonatomic, strong, readonly) MBLiBeacon *iBeacon;
@property (nonatomic, strong, readonly) MBLNeopixel *neopixel;

/**
 Current connection state of this MetaWear
 */
@property (nonatomic, readonly) CBPeripheralState state;
/**
 iOS generated unique identifier for this MetaWear
 */
@property (nonatomic, strong, readonly) NSUUID *identifier;
/**
 Stored value of signal strength at discovery time
 */
@property (nonatomic, strong) NSNumber *discoveryTimeRSSI;

/**
 Information about the device, only valid after a successful connection
 */
@property (nonatomic, strong, readonly) MBLDeviceInfo *deviceInfo;

/**
 Connect/reconnect to the MetaWear board. Once connection is complete, the provided block
 will be invoked.  If the NSError provided to the block is null then the connection
 succeeded, otherwise failure (see error for details)
 @param MBLErrorHandler handler, Callback once connection is complete
 @returns none
 */
- (void)connecWithHandler:(MBLErrorHandler)handler;

/**
 Disconnect from the MetaWear board.
 @param MBLErrorHandler handler, Callback once disconnection is complete
 @returns none
 */
- (void)disconnectWithHandler:(MBLErrorHandler)handler;

/**
 Remember this MetaWear, it will be saved to disk and retrievable
 through [[MBLMetaWearManager sharedManager] retrieveSavedMetaWears]
 */
- (void)rememberDevice;

/**
 Forget this MetaWear, it will no longer be retrievable
 through [[MBLMetaWearManager sharedManager] retrieveSavedMetaWears]
 */
- (void)forgetDevice;


/**
 Query the current RSSI
 */
- (void)readRSSIWithHandler:(MBLNumberHandler)handler;
/**
 Query the percent remaining battery life, returns int between 0-100
 */
- (void)readBatteryLifeWithHandler:(MBLNumberHandler)handler;
/**
 * @deprecated use deviceInfo property instead
 * @see deviceInfo
 */
- (void)readDeviceInfoWithHandler:(MBLDeviceInfoHandler)handler DEPRECATED_MSG_ATTRIBUTE("Use deviceInfo property instead");


/**
 Perform a software reset of the device, note this will cause the device to disconnect
 */
- (void)resetDevice;

/**
 See if this device is running the most up to date firmware
 */
- (void)checkForFirmwareUpdateWithHandler:(MBLBoolHandler)handler;

/**
 Updates the device to the latest firmware, or re-installs the latest firmware.
 Please make sure the device is charged at 50% or above to prevent errors.
 Executes the progressHandler periodically with the firmware image uploading
 progress (0.0 - 1.0), once it's called with 1.0, you can still expect another 5
 seconds while we wait for the device to install the firmware and reboot.  After
 the reboot, handler will be called and passed an NSError object if the update
 failed or nil if the update was successful.
 @param MBLErrorHandler handler, Callback once update is complete
 @param MBLFloatHandler progressHandler, Periodically called while firmware upload is in progress
 @returns none
 */
- (void)updateFirmwareWithHandler:(MBLErrorHandler)handler
                  progressHandler:(MBLFloatHandler)progressHandler;

@end
