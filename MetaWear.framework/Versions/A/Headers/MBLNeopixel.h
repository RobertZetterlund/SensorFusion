/**
 * MBLNeopixel.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/12/14.
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
#import <MetaWear/MBLModule.h>
#import <UIKit/UIKit.h>

typedef enum {
    MBLColorOrderingRGB = 0,
    MBLColorOrderingRBG = 1,
    MBLColorOrderingGRB = 2,
    MBLColorOrderingGBR = 3
} MBLColorOrdering;

typedef enum {
    MBLStrandSpeedSlow = 0,
    MBLStrandSpeedFast = 1
} MBLStrandSpeed;

typedef enum {
    MBLRotationDirectionTowardsBoard = 0,
    MBLRotationDirectionAwayFromBoard = 1
} MBLRotationDirection;

@interface MBLNeopixel : MBLModule

/**
 Initialize memory on the MetaWear board for a NeoPixel strand
 @param uint8_t index, Strand number (id) to initialize, can be in the range [0, 2]
 @param MBLColorOrdering color, Color ordering format
 @param MBLStrandSpeed speed, Operating speed
 @param uint8_t pin, GPIO pin the strand is connected to
 @param uint8_t length, Number of pixels to initialize
 */
- (void)initializeStrandAtIndex:(uint8_t)index color:(MBLColorOrdering)color speed:(MBLStrandSpeed)speed pin:(uint8_t)pin length:(uint8_t)length;

/**
 Hold Neopixel strand.
 @param uint8_t index, Strand number, can be in the range [0, 2]
 @param BOOL enable, Hold enable
 @returns none
 */
- (void)holdStrandAtIndex:(uint8_t)index withEnable:(BOOL)enable;

/**
 Clear Neopixel strand.
 @param uint8_t index, Strand number, can be in the range [0, 2]
 @param uint8_t start, Pixel index to start clearing from
 @param uint8_t end, Pixel index to clear to, inclusive
 @returns none
 */
- (void)clearStrandAtIndex:(uint8_t)index startPixel:(uint8_t)start endPixel:(uint8_t)end;

/**
 Set Pixel at strand index.
 @param uint8_t index, Strand number, can be in the range [0, 2]
 @param uint8_t pixel, Pixel index to be set
 @param UIColor color, Color the LED will be set to
 @returns none
 */
- (void)setPixelAtIndex:(uint8_t)index pixel:(uint8_t)pixel color:(UIColor *)color;

/**
 Rotate strand at index.
 @param uint8_t index, Strand number, can be in the range [0, 2]
 @param MBLRotationDirection direction, Rotation direction
 @param uint8_t repetitions, Number of times to repeat the rotation. Use 0xFF to rotate indefinitely, 0 to terminate
 @param uint16_t period, Amount of time, in milliseconds, between rotations
 @returns none
 */
- (void)rotateStrandAtIndex:(uint8_t)index direction:(MBLRotationDirection)direction repetitions:(uint8_t)repetitions period:(uint16_t)period;

/**
 Deinitialize strand at index.
 @param uint8_t index, Strand number, can be in the range [0, 2]
 @returns none
 */
- (void)deinitializeStrandAtIndex:(uint8_t)index;



/**
 * @deprecated use initializeStrandAtIndex:color:speed:pin:length: instead
 * @see initializeStrandAtIndex:color:speed:pin:length:
 */
- (void)initializeStrandAtIndex:(uint8_t)index withColor:(uint8_t)color pin:(uint8_t)pin andLength:(uint8_t)length DEPRECATED_MSG_ATTRIBUTE("Use initializeStrandAtIndex:color:speed:pin:length: instead");

/**
 * @deprecated use clearStrandAtIndex:startPixel:endPixel: instead
 * @see clearStrandAtIndex:startPixel:endPixel:
 */
- (void)clearStrandwithStartIndex:(uint8_t)start endIndex:(uint8_t)end DEPRECATED_MSG_ATTRIBUTE("Use clearStrandAtIndex:startPixel:endPixel: instead");

/**
 * @deprecated use setPixelAtIndex:pixel:color: instead
 * @see setPixelAtIndex:pixel:color:
 */
- (void)setPixelAtIndex:(uint8_t)index withRed:(uint8_t)red Green:(uint8_t)green andBlue:(uint8_t)blue DEPRECATED_MSG_ATTRIBUTE("Use setPixelAtIndex:pixel:color: instead");

/**
 * @deprecated use rotateStrandAtIndex:direction:repetitions:period: instead
 * @see rotateStrandAtIndex:direction:repetitions:period:
 */
- (void)rotateStrandAtIndex:(uint8_t)index withIncFlag:(uint8_t)flag rotateRepeat:(uint8_t)repeat andDelay:(uint16_t)delay DEPRECATED_MSG_ATTRIBUTE("Use rotateStrandAtIndex:direction:repetitions:period: instead");

@end
