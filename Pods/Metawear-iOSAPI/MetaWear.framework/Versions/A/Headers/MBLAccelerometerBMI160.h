/**
 * MBLAccelerometerBMI160.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/27/15.
 * Copyright (c) 2015 MbientLab Inc. All rights reserved.
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

#import <MetaWear/MBLAccelerometer.h>
#import <MetaWear/bmi160.h>

/**
 Accelerometer sensitiviy ranges
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerBMI160Range) {
    MBLAccelerometerBMI160Range2G = BMI160_ACCEL_RANGE_2G,
    MBLAccelerometerBMI160Range4G = BMI160_ACCEL_RANGE_4G,
    MBLAccelerometerBMI160Range8G = BMI160_ACCEL_RANGE_8G,
    MBLAccelerometerBMI160Range16G = BMI160_ACCEL_RANGE_16G,
};

/**
 Interface to on-board accelerometer
 */
@interface MBLAccelerometerBMI160 : MBLAccelerometer <NSCoding>

/**
 Maximum acceleration the accelerometer can report
 */
@property (nonatomic) MBLAccelerometerBMI160Range fullScaleRange;

@end
