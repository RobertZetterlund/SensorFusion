/**
 * MBLMetaWearConfiguration.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/23/15.
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

#import <MetaWear/MBLMetaWear.h>

/**
 A MBLMetaWearConfiguration object is used to persist state across resets and
 disconnects.  You derive an object from this class and then assing it to an
 MBLMetaWear object using the setConfiguration:handler: method.
 */
@interface MBLMetaWearConfiguration : NSObject

@property (nonatomic, readonly, weak) MBLMetaWear *device;

/**
 This function is called shortly after you assign this object to a MetaWear device.
 Override this function and use it as the main initialization point for setting up
 custom events needed for your application.
 Always call [super setupEvents];
 */
- (void)setupEvents;

///----------------------------------
/// @name NSCoding
///----------------------------------

/**
 Override this function and restore any custom MBLEvents you created
 Your first line will always be:
 self = [super initWithCoder:aDecoder];
 */
- (id)initWithCoder:(NSCoder *)aDecoder;

/**
 Override this function and save any custom MBLEvents you created
 Your first line will always be:
 [super encodeWithCoder:aCoder];
 */
- (void)encodeWithCoder:(NSCoder *)aCoder;


///----------------------------------
/// @name Advanced State Persistence
///----------------------------------

/**
 Any API calls in this method will be persisted in non-volatile memory on the
 MetaWear, and be executed when the MetaWear powers on.  For example, if you want
 the device to automatically startLogging some event, set the peripheral name, or 
 modifiy a connection parameter, do that in this function.
 
 NOTE: the MetaWear only resets after power loss or critical firmware error, 
 both of which are abnormal events.  Most people won't need these advanced capabilities.
 */
- (void)runOnDeviceBoot;

@end
