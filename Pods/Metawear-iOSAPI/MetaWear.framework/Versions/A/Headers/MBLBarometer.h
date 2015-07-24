/**
 * MBLBarometer.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 4/27/15.
 * Copyright 2015 MbientLab Inc. All rights reserved.
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
#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLModule.h>

/**
 Barometer oversampling rates
 */
typedef NS_ENUM(uint8_t, MBLBarometerOversample) {
    MBLBarometerOversampleUltraLowPower = 1,
    MBLBarometerOversampleLowPower = 2,
    MBLBarometerOversampleStandard = 3,
    MBLBarometerOversampleHighResolution = 4,
    MBLBarometerOversampleUltraHighResolution = 5,
};

/**
 Barometer output filter
 */
typedef NS_ENUM(uint8_t, MBLBarometerFilter) {
    MBLBarometerFilterOff = 0,
    MBLBarometerFilterAverage2 = 1,
    MBLBarometerFilterAverage4 = 2,
    MBLBarometerFilterAverage8 = 3,
    MBLBarometerFilterAverage16 = 4,
};

/**
 Barometer standby times
 */
typedef NS_ENUM(uint8_t, MBLBarometerStandby) {
    MBLBarometerStandby0_5 = 0,
    MBLBarometerStandby62_5 = 1,
    MBLBarometerStandby125 = 2,
    MBLBarometerStandby250 = 3,
    MBLBarometerStandby500 = 4,
    MBLBarometerStandby1000 = 5,
    MBLBarometerStandby2000 = 6,
    MBLBarometerStandby4000 = 7
};


/**
 Interface to the barometer sensor
 */
@interface MBLBarometer : MBLModule <NSCoding>

/**
 Use this to set pressure sampling mode, higher values produce more accurate
 results but will use more power.
 */
@property (nonatomic) MBLBarometerOversample pressureOversampling;
/**
 Use this to set hardware average filtering of pressure samples.
 */
@property (nonatomic) MBLBarometerFilter hardwareAverageFilter;
/**
 Set the standby time for the periodicAltitidue and periodicPressure events.
 That is how long the device sleeps between successive measurements
 */
@property (nonatomic) MBLBarometerStandby standbyTime;


/**
 Data representing the atmospheric pressure measured by barometer.
 Event callbacks will be provided an MBLNumericData object whose float
 value will be pressure in pascals.
 */
@property (nonatomic, strong, readonly) MBLData *pressure;
/**
 Data representing the altidue calulated from atmospheric pressure.
 Event callbacks will be provided an MBLNumericData object whose float
 value will be altitude in meters.
 */
@property (nonatomic, strong, readonly) MBLData *altitude;


/**
 Data representing the atmospheric pressure measured by barometer. Period
 of event will depend on pressureOversampling and standbyTime.
 Event callbacks will be provided an MBLNumericData object whose float
 value will be pressure in pascals.
 */
@property (nonatomic, strong, readonly) MBLEvent *periodicPressure;
/**
 Event representing the altidue calulated from atmospheric pressure. Period
 of event will depend on pressureOversampling and standbyTime.
 Event callbacks will be provided an MBLNumericData object whose float
 value will be altitude in meters.
 */
@property (nonatomic, strong, readonly) MBLEvent *periodicAltitude;

@end
