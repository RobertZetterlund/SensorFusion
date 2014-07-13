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
@property (strong,nonatomic) CBPeripheral *connectingPeripheral; /**< CBPeripheral class for BLE functionality */
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
@property (strong,nonatomic) Neopixel *neopixel; /**< Neopixel class */
@property (strong,nonatomic) Beacon *beacon; /**< Beacon class */

@property (nonatomic) int count;

///// Scanning MetaWear API calls /////

/** 
 Start Scanning for MetaWear devices. This will trigger the MetaWear delegate callback devicesFound()
 @param CBUUID scanUUID, UUID of the device, can be nil (16 bytes or 1 byte)
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
 @param CBPeripheral metawear, MetaWear device to connect to
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
 @param none
 @returns none
 */
- (void)getRSSI;


///// SWITCH MetaWear API calls /////

/**
 Get the current state of the switch/button. This will trigger the MetaWear delegate callback retrieveSwitchValue()
 @param int mode, mode to set notification state (0: stop notify, 1: start notify, else: read) (1 byte)
 @returns none
 */
- (void)getSwitchStatewithOptions:(int)mode;

///// LED MetaWear API calls /////

/** 
 Turn on LED.  This will trigger the MetaWear delegate callback writeSuccess()
 @param int mode, mode to set led state (0: pause, 1: play, 2/else: autoplay) (1 byte)
 @returns none
 */
- (void)toggleOnLEDwithOptions:(int)mode;

/**
 Turn off LED. This will trigger the MetaWear delegate callback writeSuccess()
 @param int mode, mode to set led state (0: pause, 1/else: stop and reset all channels) (1 byte)
 @returns none
 */
- (void)toggleOffLEDwithOptions:(int)mode;

/**
 Set the LED color mode. This will trigger the MetaWear delegate callback writeSuccess()
 @param int channel, color 0:G, 1:R, 2:B (1 byte)
 @param int onint, ON Intensity (0-31) (1 byte)
 @param int ofint, OFF Intensity (0-31) (1 byte)
 @param int rtime, Time Rise (2 bytes) (used for Flash mode only)
 @param int otime, Time On (2 bytes)
 @param int ftime, Time Fall (2 bytes) (used for Flash mode only)
 @param int period, Time Period (2 bytes)
 @param int offset, Time Offset (2 bytes)
 @param int repeat, Repeat Count (0-254) (1 byte)
 @returns none
 */
- (void)setLEDModewithColorChannel:(int)channel onIntensity:(int)onint offIntensity:(int)ofint riseTime:(int)rtime fallTime:(int)ftime onTime:(int)otime period:(int)period offset:(int)offset repeatCount:(int)repeat;

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
 @param int mode, mode to set notification state (1: notify, nil/0/else: read) (1 byte)
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
 Get the temperature. This will trigger the MetaWear delegate callback retrieveTemperature()
 @returns none
 */
- (void)enableTemperatureRead;

///// GPIO API calls /////

/**
 Turn on/off a output GPIO Pin, a digital 1 or 0. This will trigger the MetaWear delegate callback writeSuccess()
 @param int pinNumber, number of the pin (1 byte)
 @returns none
 */
- (void)setDigitalPin:(int)pinNumber;

/**
 Get GPIO Pin status. This will trigger the MetaWear delegate callback writeSuccess()
 @param int pin, number of the pin (1 byte)
 @returns none
 */
- (void)clearDigitalPin:(int)pinNumber;

/**
 Set input GPIO pin type. This will trigger the MetaWear delegate callback writeSuccess()
 @param int pinNumber, number of the pin (1 byte)
 @param int type, option type (0: pullup, 1: pulldown, 2/else: nopull) (1 byte)
 @returns none
 */
- (void)setPin:(int)pinNumber withOptions:(int)type;

/**
 Read Analog value of GPIO Pin. This will trigger the MetaWear delegate callback retrieveGPIOValue()
 @param int pinNumber, number of the pin (1 byte)
 @param int option, opcode (0: use internal Vref, 1/else: use supply voltage ratio) (1 byte)
 @returns none
 */
- (void)readAnalogPin:(int)pinNumber withOptions:(int)option;

/**
 Read Digital value of GPIO Pin. This will trigger the MetaWear delegate callback retrieveGPIOValue()
 @param int pinNumber, number of the pin (1 byte)
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

///// Neopixel API calls /////

/**
 Initialize the Neopixel thread. This will trigger the MetaWear delegate callback writeSuccess()
 @param int index, strand index (1 byte)
 @param int color, color order and speed (1 byte)
 @param int pin, I/O pin (1 byte)
 @param int length, strand length (1 byte)
 @returns none
 */
- (void)initializeStrandAtIndex:(int)index withColor:(int)color pin:(int)pin andLength:(int)length;

/**
 Hold Neopixel strand. This will trigger the MetaWear delegate callback writeSuccess()
 @param int index, strand index (1 byte)
 @param int enable, hold enable (1 byte)
 @returns none
 */
- (void)holdStrandAtIndex:(int)index withEnable:(BOOL)enable;

/**
 Clear Neopixel strand. This will trigger the MetaWear delegate callback writeSuccess()
 @param int start, start index (1 byte)
 @param int end, stop index (1 byte)
 @returns none
 */
- (void)clearStrandwithStartIndex:(int)start endIndex:(int)end;

/**
 Set Pixel at strand index. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)setPixelAtIndex:(int)index withRed:(int)red Green:(int)green andBlue:(int)blue;

/**
 Rotate strand at index. This will trigger the MetaWear delegate callback writeSuccess()
 @param int index, strand index (1 byte)
 @param int flag, increment flag (1 byte)
 @param int repeat, rotate repeat (1 byte)
 @param int delay, delay in ms (2 bytes)
 @returns none
 */
- (void)rotateStrandAtIndex:(int)index withIncFlag:(int)flag rotateRepeat:(int)repeat andDelay:(int)delay;

/**
 Deinitialize strand at index. This will trigger the MetaWear delegate callback writeSuccess()
 @param int index, strand index (1 byte)
 @returns none
 */
- (void)deinitializeStrandAtIndex:(int)index;

/**
 Read Neopixel info. This will trigger the MetaWear delegate callback retrieveDeviceInfo()
 @param int index, strand index (1 byte)
 @returns none
 */
- (void)readStrandInfoForIndex:(int)index;

///// iBeacon API calls /////

/**
 Enable iBeacon mode. This will trigger the MetaWear delegate callback writeSuccess()
 @param CBUUID UUID as a 16 Byte UUID, the default is the MetaWear Service UUID (16 bytes)
 @param int major, the default is 0x0000 (2 bytes)
 @param int minor, the default is 0x0000 (2 bytes)
 @returns none
 */
- (void)setBeaconModewithUUID:(CBUUID*)uuid Major:(int)major andMinor:(int)minor;

/**
 Enable iBeacon mode. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)enableBeaconMode;

/**
 Disable iBeacon mode. This will trigger the MetaWear delegate callback writeSuccess()
 @param none
 @returns none
 */
- (void)disableBeaconMode;

/**
 Set iBeacon options. This will trigger the MetaWear delegate callback writeSuccess()
 @param int powerRX, calibrated RX power, default is -55 dBm (1 byte)
 @param int powerTX, TX power, default is 0 dBm (1 byte)
 @param int frequency, advertisement frequency in ms, default is 500 ms (2 bytes)
 @returns none
 */
- (void)setBeaconOptionswithRXPower:(int)powerRX TXPower:(int)powerTX andFrequency:(int)frequency;

/**
 Read iBeacon options. This will trigger the MetaWear delegate callback retrieveBeaconInfo()
 @param none
 @returns none
 */
- (void)readBeaconOptions;

///// Haptic MetaWear API calls /////

/**
 Turn on Haptic Driver.  This will trigger the MetaWear delegate callback writeSuccess()
 @param int dcycle, duty cycle (1 byte)
 @param int pwidth, pulse width (2 bytes)
 @returns none
 */
- (void)toggleOnHapticwithDutyCycle:(int)dcycle pulseWidth:(int)pwidth;

///// Buzzer MetaWear API calls /////

/**
 Turn on Buzzer.  This will trigger the MetaWear delegate callback writeSuccess()
 @param int pwidth, pulse width (2 bytes)
 @returns none
 */
- (void)toggleOnBuzzerwithPulseWidth:(int)pwidth;

@end
