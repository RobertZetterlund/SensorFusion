/**
 * MBLMetaWearManager.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/29/14.
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

#import <MetaWear/MBLMetaWear.h>
#import <MetaWear/MBLConstants.h>

@interface MBLMetaWearManager : NSObject

/**
 Access the single WetaWearManager object, note you should not create
 one of these objects on your own, only used the sharedManager
 @returns MBLMetaWearManager, Single manager object
 */
+ (instancetype)sharedManager;

/**
 Sets the queue for which all callbacks will occur on.  Defaults to the main queue.
 @param NSOperationQueue queue, The queue on which the events will be dispatched.
 @returns none
 */
- (void)setCallbackQueue:(NSOperationQueue *)queue;

/**
 Returns a list of saved MetaWear objects, you add to this list by calling rememberDevice
 on an MBLMetaWear object.
 @param MBLArrayHandler handler, Callback to deliever list remembered MBLMetaWear objects
 @returns none
 */
- (void)retrieveSavedMetaWearsWithHandler:(MBLArrayHandler)handler;

/**
 Begin scanning for MetaWear devices. This will invoke the provided block each time a
 new device shows up and passes an array of all discovered devices to the block.
 This continues until stopScanForMetaWears is called.
 @param MBLArrayHandler handler, Callback to handle each time a new device is found
 @returns none
 */
- (void)startScanForMetaWearsWithHandler:(MBLArrayHandler)handler;
/**
 Begin scanning for MetaWear devices with the option to filter duplicate devices or not.
 This will invoke the provided block each time a new device shows up if filter == YES or
 each time a new advertising packet is found if filter == NO (may be many times per second).
 This can be useful in specific situations, such as making a connection based on a 
 MetaWear's RSSI, but may have an adverse affect on battery-life and application performance,
 so use wisely.  This continues until stopScanForMetaWears is called.
 @param BOOL duplicates, YES: only callback when a new device is found, NO: callback each time
 @param MBLArrayHandler handler, Callback to handle each time a new device is found
 a new advertising packet is found
 @returns none
 */
- (void)startScanForMetaWearsAllowDuplicates:(BOOL)duplicates handler:(MBLArrayHandler)handler;

/**
 Stop scanning for MetaWear devices, this will release all handlers given to
 startManagerStateUpdatesWithHandler:
 @returns none
 */
- (void)stopScanForMetaWears;


/**
 * @deprecated use connectMetaWear:connectionHandler:disconnectionHandler: instead
 * @see connectMetaWear:connectionHandler:disconnectionHandler:
 */
- (void)connectMetaWear:(MBLMetaWear *)device withHandler:(MBLErrorHandler)handler DEPRECATED_MSG_ATTRIBUTE("Use connectMetaWear:connectionHandler:disconnectionHandler: instead");
/**
 * @deprecated use cancelMetaWearConnection: instead
 * @see cancelMetaWearConnection:
 */
- (void)cancelMetaWearConnection:(MBLMetaWear *)device withHandler:(MBLErrorHandler)handler DEPRECATED_MSG_ATTRIBUTE("Use cancelMetaWearConnection: instead");

@end
