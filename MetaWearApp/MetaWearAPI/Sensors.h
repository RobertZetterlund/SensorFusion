//
//  Sensors.h
//
//  Created by Laura Kassovic on 10/2/12.
//  Copyright (c) 2012 MbientLab Inc. All rights reserved.
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
#import <UIKit/UIKit.h>

/// Class for Switch Button
@interface Switch : NSObject

@property (nonatomic) int state; /**< Button State; 1: Switch Pressed, 0: Switch Released */
-(int) calcState:(NSData *)data;

@end

/// Class for Led Sensor
@interface Led : NSObject

@property (strong, nonatomic) UIColor *color; /**< LED Color; R, G, B values as UIColor */
@property (nonatomic) int mode; /**< Mode; 1: Blink LED, 0: Flash LED */
@property (nonatomic) int onIntensity; /**< On Intensity; 0-31 */
@property (nonatomic) int offIntensity; /**< Off Intensity; 0-31 */
@property (nonatomic) int riseTime; /**< Rise Time */
@property (nonatomic) int onTime; /**< On Time */
@property (nonatomic) int fallTime; /**< Fall Time */
@property (nonatomic) int periodTime; /**< Time Period */
@property (nonatomic) int offsetTime; /**< Time Offest */
@property (nonatomic) int repeatCount; /**< Time Offest */

-(void) calcMode:(NSData *)data;

@end

/// Class for Accelerometer Sensor
@interface Accelerometer : NSObject

@property (nonatomic) int globalEnable; /**< Accelerometer Global enable; 0: Disable, 1: Enable */
@property (nonatomic) int dataEnable; /**< Accelerometer Data enable for XYZ values; 0: Disable, 1: Enable */
//@property (nonatomic) int dataConfig; /**< TBD */
@property (nonatomic) float x; /**< Accelerometer X-axis data, 12 bits, 1024 counts [-512/512] that represents [-2g/2g] */
@property (nonatomic) float y; /**< Accelerometer Y-axis data, 12 bits, 1024 counts [-512/512] that represents [-2g/2g] */
@property (nonatomic) float z; /**< Accelerometer Z-axis data, 12 bits, 1024 counts [-512/512] that represents [-2g/2g] */
//@property (nonatomic) int motionEnable; /**< TBD; 0: Disable, 1: Enable */
//@property (nonatomic) int motionConfig; /**< TBD */
//@property (nonatomic) int motionStatus; /**< TBD */
//@property (nonatomic) int orientationEnable; /**< TBD; 0: Disable, 1: Enable */
//@property (nonatomic) int orientationStatus; /**< TBD */
//@property (nonatomic) int pulseEnable; /**< TBD; 0: Disable, 1: Enable */
//@property (nonatomic) int pulseConfig; /**< TBD */
//@property (nonatomic) int pulseStatus; /**< TBD */
//@property (nonatomic) int transientEnable; /**< TBD; 0: Disable, 1: Enable */
//@property (nonatomic) int transientConfig; /**< TBD */
//@property (nonatomic) int transientStatus; /**< TBD */
-(int) calcGlobalEnable:(NSData *)data;
-(int) calcDataEnable:(NSData *)data;
-(void) calcXYZ:(NSData *)data;
//-(int) calcMotionEnable:(NSData *)data;
//-(int) calcOrientationEnable:(NSData *)data;
//-(int) calcPulseEnable:(NSData *)data;
//-(int) calcTransientEnable:(NSData *)data;

@end

/// Class for Temperature Sensor
@interface Temperature : NSObject

@property (nonatomic) float temperatureValue; /**< Temperature: 16 bit signed int in units of 1.0C */
-(float) calcTemp:(NSData *)data;

@end

/// Class for GPIO Pins
@interface GPIO : NSObject

@property (nonatomic) int pinDIO0Value; /**< GPIO Pin DIO0 value; Analog: raw value in MV or 10-bit supply ratio, Digital: 1 or 0 */
@property (nonatomic) int pinDIO1Value; /**< GPIO Pin DIO1 value; Analog: raw value in MV or 10-bit supply ratio, Digital: 1 or 0 */
-(int) calcAnalog:(NSData *)data;
-(int) calcDigital:(NSData *)data;

@end

/// Class for DeviceInfo Service
@interface DeviceInfo : NSObject

@property (strong, nonatomic) NSMutableString *manufacturerName; /**< DeviceInfo Manufacturer Name string */
@property (strong, nonatomic) NSMutableString *serialNumber; /**< DeviceInfo Serial Number string */
@property (strong, nonatomic) NSMutableString *hardwareRev; /**< DeviceInfo Hardware Revision string */
@property (strong, nonatomic) NSMutableString *firmwareRev; /**< DeviceInfo Firmware Revision string */
-(NSString*) getManuString:(NSData *)data;
-(NSString*) getSerialNumString:(NSData *)data;
-(NSString*) getHwRevString:(NSData *)data;
-(NSString*) getFwRevString:(NSData *)data;

@end

/// Class for Battery Service
@interface Battery : NSObject

@property (nonatomic) int batteryLife; /**< Battery life percentage; 0 to 100% */
-(int) calcBatt:(NSData *)data;

@end

/// Class for Neopixel Service
@interface Neopixel : NSObject

@property (nonatomic) int strandIndex; /**< strand index */
@property (nonatomic) int colorOrder; /**< color order and speed */
@property (nonatomic) int pin; /**< I/O pin */
@property (nonatomic) int strandLength; /**< strand length */
@property (nonatomic) int holdState; /**< hold enable state */
@property (nonatomic) int pixelIndex; /**< pixel index */
@property (nonatomic) int incFlag; /**< increment or decrement for rotation */
@property (nonatomic) int rotateRepeat; /**< repeat rotation */
@property (nonatomic) int delay; /**< delay in ms (2 bytes) */
@property (nonatomic) int r; /**< red color */
@property (nonatomic) int g; /**< green color */
@property (nonatomic) int b; /**< blue color */
-(void) calcInitInfo:(NSData *)data;
-(void) calcHoldInfo:(NSData *)data;
-(void) calcPixelInfo:(NSData *)data;
-(void) calcRotateInfo:(NSData *)data;

@end

/// Class for Beacon Service
@interface Beacon : NSObject

@property (nonatomic) int enable; /**< iBeacon mode enable; 0: Disable, 1: Enable */
@property (strong, nonatomic) NSUUID *mwUUID; /**< UUID: 16 byte UUID */
@property (nonatomic) int major; /**< major value; default 0x0000 */
@property (nonatomic) int minor; /**< minor value; default 0x0000 */
@property (nonatomic) int calibratedRX; /**< calibrated RX Power value; default -55 dBm */
-(int) calcEnable:(NSData *)data;
-(NSUUID*) calcUUID:(NSData *)data;
-(int) calcMajor:(NSData *)data;
-(int) calcMinor:(NSData *)data;
-(int) calcRX:(NSData *)data;

@end

/// Class for Haptic Service
@interface Haptic : NSObject

@property (nonatomic) int enable; /**< haptic driver enable; 0: Disable, 1: Enable */
@property (nonatomic) int dutyCycle; /**< duty cycle; 0-248 */
@property (nonatomic) int pulseWidth; /**< pulse width in ms; little endian */
-(int) calcEnable:(NSData *)data;
-(int) calcDutyCycle:(NSData *)data;
-(int) calcPulseWidth:(NSData *)data;

@end

/// Class for Buzzer Service
@interface Buzzer : NSObject

@property (nonatomic) int enable; /**< buzzer driver enable; 0: Disable, 1: Enable */
-(int) calcEnable:(NSData *)data;


@end

/// End of Sensors