/**
 * MBLAccelerometerBoschFormat.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/27/15.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
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
 * contact MbientLab via email: hello@mbientlab.com
 */

#import "MBLAccelerometerBoschFormat.h"
#import "MBLAccelerometerData+Private.h"
#import "MBLNumericData+Private.h"

@implementation MBLAccelerometerBoschFormat

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer packed:(BOOL)packed
{
    self = [super initArrayWithLength:packed ? 18 : 6 elements:3];
    if (self) {
        self.accelerometer = accelerometer;
        self.packed = packed;
    }
    return self;
}

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer axis:(uint8_t)axis
{
    assert(__builtin_popcount(axis) == 1);
    MBLAccelerometerAxis typedAxis = axis;
    switch (typedAxis) {
        case MBLAccelerometerAxisX:
            self = [super initNumberWithLength:2 isSigned:YES offset:0];
            break;
        case MBLAccelerometerAxisY:
            self = [super initNumberWithLength:2 isSigned:YES offset:2];
            break;
        case MBLAccelerometerAxisZ:
            self = [super initNumberWithLength:2 isSigned:YES offset:4];
            break;
    }
    if (self) {
        self.accelerometer = accelerometer;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLAccelerometerBoschFormat *newFormat = [super copyWithZone:zone];
    newFormat.accelerometer = self.accelerometer;
    return newFormat;
}

- (id)singleEntryFromData:(NSData *)data date:(NSDate *)date
{
    double x = DBL_MIN, y = DBL_MIN, z = DBL_MIN;
    const uint8_t *bytes = data.bytes;
    double scale;
    switch (self.accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange16G:
            scale = 16.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 8.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 4.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange2G:
            scale = 2.0 / 32768.0;
            break;
    }
    x = (double)(*(int16_t *)&bytes[0]) * scale;
    if (self.type == MBLFormatTypeArray) {
        y = (double)(*(int16_t *)&bytes[2]) * scale;
        z = (double)(*(int16_t *)&bytes[4]) * scale;
    }
    
    if (self.type == MBLFormatTypeArray) {
        return [[MBLAccelerometerData alloc] initWithX:x y:y z:z timestamp:date];
    } else {
        return [[MBLNumericData alloc] initWithNumber:[NSNumber numberWithDouble:x] timestamp:date];
    }
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    if (self.packed) {
        return @[[self singleEntryFromData:[data subdataWithRange:NSMakeRange(0, 6)] date:date],
                 [self singleEntryFromData:[data subdataWithRange:NSMakeRange(6, 6)] date:date],
                 [self singleEntryFromData:[data subdataWithRange:NSMakeRange(12, 6)] date:date]];
    } else {
        return [self singleEntryFromData:data date:date];
    }
}

- (NSNumber *)numberFromDouble:(double)value
{
    double scale;
    switch (self.accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange16G:
            scale = 16.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 8.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 4.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange2G:
            scale = 2.0 / 32768.0;
            break;
    }
    return [NSNumber numberWithInt:value / scale];
}

@end
