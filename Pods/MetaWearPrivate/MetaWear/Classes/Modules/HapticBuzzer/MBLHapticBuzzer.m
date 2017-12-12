/**
 * MBLHapticBuzzer.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/2/14.
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

#import "MBLHapticBuzzer.h"
#import "MBLRegister+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLMetaWearManager+Private.h"

@interface MBLHapticBuzzer ()
@property (nonatomic) MBLRegister *pulse;
@end

@implementation MBLHapticBuzzer

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.pulse = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
	}
    return self;
}

- (BFTask *)startHapticWithDutyCycleAsync:(uint8_t)dcycle pulseWidth:(uint16_t)pwidth completion:(MBLVoidHandler)completion
{
    //Byte 3: 0: 2kHz, 1: 4kHz (4kHz for Buzzer, 2kHz for Motor)
    uint8_t data[] = { dcycle, (pwidth & 0xff), (pwidth >> 8), 0x00 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    
    if (completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, pwidth * NSEC_PER_MSEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[MBLMetaWearManager dispatchQueue] addOperationWithBlock:^{
                completion();
            }];
        });
    }
    return [self.pulse writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}

- (BFTask *)startBuzzerWithPulseWidthAsync:(uint16_t)pwidth completion:(MBLVoidHandler)completion
{
    uint8_t data[] = { 124, (pwidth & 0xff), (pwidth >> 8), 0x01 };
    int dataSize = sizeof(data) / sizeof(data[0]);

    if (completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, pwidth * NSEC_PER_MSEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[MBLMetaWearManager dispatchQueue] addOperationWithBlock:^{
                completion();
            }];
        });
    }
    return [self.pulse writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}


@end
