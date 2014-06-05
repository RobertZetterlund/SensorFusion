//
//  MetaWearAPI.h
//  MetaWearAPI
//
//  Created by Laura Kassovic on 4/6/14.
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
#import <CoreBluetooth/CoreBluetooth.h>
#import "MetaWearDelegate.h"
#import "BLEUtility.h"
#import "BLEDevice.h"
#import "Sensors.h"

#define MetaWear_Base_UUID 326A9000-85CB-9195-D9DD-464CFBBAE75A

/// MetaWearAPI Class for controlling Bluetooth connections, the board, GPIOs, peripherals, and sensors.
@interface MetaWearAPI : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (assign) id <MetaWearDelegate> delegate; /**< MetaWear delegate class for API callbacks */
@property (strong,nonatomic) CBCentralManager *m; /**< CBCentral Manager class for BLE functionality */
@property (strong) CBPeripheral *connectingPeripheral; /**< CBPeripheral class for BLE functionality */
@property (strong,nonatomic) BLEDevice *d; /**< BLE MetaWear device we are currently connected to */
@property (strong,nonatomic) NSMutableArray *sensorsEnabled; /**< List of enabled sensors */
@property (strong,nonatomic) NSMutableArray *visibleDevices; /**< Visible devices from a BLE scan */

@property (strong,nonatomic) Switch *switchSensor; /**< Switch class */
@property (strong,nonatomic) Led *ledSensor; /**< Led class */
@property (strong,nonatomic) Accelerometer *accelerometerSensor; /**< Accelerometer class */
@property (strong,nonatomic) Temperature *temperatureSensor; /**< Temperature class */
@property (strong,nonatomic) GPIO *gpioSensor; /**< GPIO class */
@property (strong,nonatomic) Battery *batterySensor; /**< Battery class */
@property (strong,nonatomic) DeviceInfo *deviceSensor; /**< DeviceInfo class */

///// Scanning MetaWear API calls /////

/** 
 Start Scanning for MetaWear devices. This will trigger the MetaWear delegate callback devicesFound()
 @param CBUUID of the device, can be nil
 @returns none
 */
- (void)startScan:(CBUUID *)scanUUID;

/**
 Stop Scanning for MetaWear devices
 @param none
 @returns none
 */
- (void)stopScan;

/**
 Connect to MetaWear board chosen. This will trigger the MetaWear delegate callback connectionForDevice()
 @param CBPeripheral MetaWear device to connect to
 @returns none
 */
- (void)connectToDevice:(CBPeripheral *)metawear;

/**
 Disconnect the MetaWear board currently connected. This will trigger the MetaWear delegate callback disconnectionForDevice()
 @param none
 @returns none
 */
- (void)disconnectDevice;

/**
 Disconnect the MetaWear board currently connected. This will trigger the MetaWear delegate callback disconnectionForDevice()
 @param CBPeripheral MetaWear device to disconnect
 @returns none
 */
- (void)getRSSI;


///// SWITCH MetaWear API calls /////

/**
 Get the current state of the switch/button. This will trigger the MetaWear delegate callback retrieveSwitchValue()
 @param int mode to set notification state (0: stop notify, 1: start notify, else: read)
 @returns none
 */
- (void)getSwitchStatewithOptions:(int)mode;

///// LED MetaWear API calls /////

/** 
 Turn on LED.  This will trigger the MetaWear delegate callback writeSuccess()
 @param int mode (0: On, 1/else: toggle the LED at 1KHz)
 @returns none
 */
- (void)toggleOnLEDwithOptions:(int)mode;

/**
 Turn off LED. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)toggleOffLED;

/**
 Set the LED color with RGB UIColor value. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)setColorLED:(UIColor *)color;

/**
 Get current LED state. This will trigger the MetaWear delegate callback retrieveLEDData()
 @param none
 @returns none
 */
- (void)getLEDStatus;

///// Accelerometer API calls /////

/**
 Turn on the accelerometer, global enable. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)enableGlobalAccelerometer;

/**
 Turn off the accelerometer, global enable. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)disableGlobalAccelerometer;

/**
 Turn on the accelerometer. This will trigger the MetaWear delegate callback retrieveAccelerometerData()
 @param int mode to set notification state (1: notify, nil/0/else: read)
 @returns none
 */
- (void)enableXYZMotionwithOptions:(int)mode;

/**
 Turn off the accelerometer. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)disableXYZMotion;

///// Temperature API calls /////

/**
 Get the current state of the switch/button. This will trigger the MetaWear delegate callback retrieveTemperature()
 @param int mode (any value = read)
 @returns none
 */
- (void)enableTemperatureReadwithOptions:(int)mode;

///// GPIO API calls /////

/**
 Turn on/off a output GPIO Pin, a digital 1 or 0. This will trigger the MetaWear delegate callback writeSuccess()
 @param int pin number of the pin
 @param bool digital val for the pin (0 or 1)
 @returns none
 */
- (void)setDigitalPin:(int)pinNumber;

/**
 Get GPIO Pin status. This will trigger the MetaWear delegate callback writeSuccess()
 @param int pin number of the pin
 @returns none
 */
- (void)clearDigitalPin:(int)pinNumber;

/**
 Set input GPIO pin type. This will trigger the MetaWear delegate callback writeSuccess()
 @param int pin number of the pin
 @param int option type (0: pullup, 1: pulldown, 2/else: nopull)
 @returns none
 */
- (void)setPin:(int)pinNumber withOptions:(int)type;

/**
 Read Analog value of GPIO Pin. This will trigger the MetaWear delegate callback retrieveGPIOValue()
 @param int pin number of the pin
 @param int option opcode (0: use internal Vref, 1/else: use supply voltage ratio)
 @returns none
 */
- (void)readAnalogPin:(int)pinNumber withOptions:(int)option;

/**
 Read Digital value of GPIO Pin. This will trigger the MetaWear delegate callback retrieveGPIOValue()
 @param int pin number of the pin
 @returns none
 */
- (void)readDigitalPin:(int)pinNumber;

///// Teset/Debug API calls /////

/**
 Reset board
 @param none
 @returns none
 */
- (void)resetDevice;

/**
 Enter Bootloader mode
 @param none
 @returns none
 */
- (void)jumpToBootloader;

///// Battery API calls /////

/**
 Read current battery percentage. This will trigger the MetaWear delegate callback retrieveBatteryInfo()
 @param none
 @returns none
 */
- (void)readBatteryLife;

///// Device Info API calls /////

/**
 Read device info. This will trigger the MetaWear delegate callback retrieveDeviceInfo()
 @param none
 @returns none
 */
- (void)readDeviceInfo;


@end
