/**
 * MBLGPIO.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/2/14.
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

#import <MetaWear/MBLConstants.h>

typedef enum {
    MBLPinConfigurationPullup = 0,
    MBLPinConfigurationPulldown = 1,
    MBLPinConfigurationNopull = 2
} MBLPinConfiguration;

typedef enum {
    MBLAnalogReadModeFixed = 0,
    MBLAnalogReadModeSupplyRatio = 1
} MBLAnalogReadMode;

@interface MBLGPIO : NSObject

/**
 Set a digital output GPIO Pin to a 1 or 0.
 @param uint8_t pinNumber, number of the pin
 @param BOOL on, YES sets pin to 1, NO clears pin to 0
 @returns none
 */
- (void)setPin:(uint8_t)pinNumber toDigitalValue:(BOOL)on;

/**
 Set input GPIO pin type.
 @param uint8_t pinNumber, number of the pin
 @param MBLPinConfiguration type, pin configuration type
 @returns none
 */
- (void)configurePin:(uint8_t)pinNumber type:(MBLPinConfiguration)type;

/**
 Read Analog value of GPIO Pin.
 @param uint8_t pinNumber, number of the pin
 @param MBLAnalogReadMode mode, MBLAnalogReadModeFixed gives a reading in actual volts,
 when MBLAnalogReadModeSupplyRatio is used, the numbers comes back [0, 1.0] where 0 indicates
 then input is equal to ground, and 1.0 indicates the input is equal to the supply voltage
 @param MBLDecimalNumberHandler handler, Callback once read is complete
 @returns none
 */
- (void)readAnalogPin:(uint8_t)pinNumber mode:(MBLAnalogReadMode)mode handler:(MBLDecimalNumberHandler)handler;

/**
 Read Digital value of GPIO Pin.
 @param uint8_t pinNumber, number of the pin
 @param MBLBoolHandler handler, Callback once read is complete
 @returns none
 */
- (void)readDigitalPin:(uint8_t)pinNumber handler:(MBLBoolHandler)handler;



/**
 * @deprecated use configurePin:type: instead
 * @see configurePin:type:
 */
- (void)configurePin:(uint8_t)pinNumber withOptions:(uint8_t)type DEPRECATED_MSG_ATTRIBUTE("Use configurePin:type: instead");

/**
 * @deprecated use readDigitalPin:handler: instead
 * @see readDigitalPin:handler:
 */
- (void)readDigitalPin:(uint8_t)pinNumber withHander:(MBLBoolHandler)handler DEPRECATED_MSG_ATTRIBUTE("Use readDigitalPin:handler: instead");

/**
 * @deprecated use readAnalogPin:mode:handler: instead
 * @see readAnalogPin:mode:handler:
 */
- (void)readAnalogPin:(uint8_t)pinNumber usingOptions:(uint8_t)option withHandler:(MBLDecimalNumberHandler)handler DEPRECATED_MSG_ATTRIBUTE("Use readAnalogPin:mode:handler: instead");

@end
