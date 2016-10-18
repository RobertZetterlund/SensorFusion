/**
 * MBLMetaWear.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/29/14.
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

#import "MBLMetaWear.h"
#import "MBLMetaWear+Private.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLFirmwareUpdateManager.h"
#import "MBLAnalytics.h"
#import "MBLModuleInfo.h"
#import "MBLFirmwareBuild.h"
#import "MBLFormat.h"
#import "MBLNumericFormatter.h"
#import "MBLNumericData+Private.h"
#import "FastCoder.h"
#import "BFTask+MBLExtensions.h"
#import "BFTask+Private.h"

#import "MBLMechanicalSwitch.h"
#import "MBLAccelerometer+Private.h"
#import "MBLGyro+Private.h"
#import "MBLTemperature.h"
#import "MBLLED.h"
#import "MBLGPIO.h"
#import "MBLTestDebug.h"
#import "MBLEvent+Private.h"
#import "MBLANCS.h"
#import "MBLTimer+Private.h"
#import "MBLSettings.h"
#import "MBLNeopixel.h"
#import "MBLiBeacon.h"
#import "MBLHapticBuzzer.h"
#import "MBLSerial+Private.h"
#import "MBLDeviceInfo.h"
#import "MBLConductance.h"
#import "MBLBarometer.h"
#import "MBLAmbientLight+Private.h"
#import "MBLMagnetometer.h"
#import "MBLHygrometer.h"
#import "MBLPhotometer+Private.h"
#import "MBLProximity+Private.h"
#import "MBLSettings+Private.h"
#import "MBLDispatchQueue.h"
#import <objc/runtime.h>
#import "MBLMovingAverage.h"
#import "MBLConstants+Private.h"
#import "MBLLogger.h"

static int MAX_PENDING_WRITES = 25;

typedef void (^MBLModuleInfoErrorHandler)(MBLModuleInfo *moduleInfo, NSError *error);
typedef void (^MBLModuleInfoHandler)(MBLModuleInfo *moduleInfo);

@interface MBLMetaWear ()
// Properties from MBLMetaWear.h
@property (nonatomic, nullable) MBLMechanicalSwitch *mechanicalSwitch;
@property (nonatomic, nullable) MBLLED *led;
@property (nonatomic, nullable) MBLTemperature *temperature;
@property (nonatomic, nullable) MBLAccelerometer *accelerometer;
@property (nonatomic, nullable) MBLGyro *gyro;
@property (nonatomic, nullable) MBLGPIO *gpio;
@property (nonatomic, nullable) MBLHapticBuzzer *hapticBuzzer;
@property (nonatomic, nullable) MBLiBeacon *iBeacon;
@property (nonatomic, nullable) MBLNeopixel *neopixel;
@property (nonatomic, nullable) MBLANCS *ancs;
@property (nonatomic, nullable) MBLTimer *timer;
@property (nonatomic, nullable) MBLSerial *serial;
@property (nonatomic, nullable) MBLConductance *conductance;
@property (nonatomic, nullable) MBLBarometer *barometer;
@property (nonatomic, nullable) MBLAmbientLight *ambientLight;
@property (nonatomic, nullable) MBLMagnetometer *magnetometer;
@property (nonatomic, nullable) MBLHygrometer *hygrometer;
@property (nonatomic, nullable) MBLPhotometer *photometer;
@property (nonatomic, nullable) MBLProximity *proximity;
@property (nonatomic, nullable) MBLSettings *settings;
@property (nonatomic, nullable) MBLDeviceInfo *deviceInfo;

@property (nonatomic, nullable) id<MBLRestorable> configuration;

@property (nonatomic) MBLConnectionState state;
@property (nonatomic) BOOL isGuestConnection;
@property (nonatomic, nonnull) NSUUID *identifier;
@property (nonatomic, nullable) NSNumber *discoveryTimeRSSI;
@property (nonatomic) MBLMovingAverage *rssiAverager;
//@property (nonatomic, nonnull) NSString *name;
// Setting the name property causes side effects, so we
// create an internal property for storing the actual value, allowing
// us to safely get/set during serialization of this class
@property (nonatomic) NSString *nameImpl;


// Properties from MBLMetaWear+Private.h
@property (nonatomic) BOOL bypassSetup;

@property (nonatomic) id<MBLBluetoothPeripheral> peripheral;

@property (nonatomic) MBLDataProcessor *dataProcessor;
@property (nonatomic) MBLLogging *logging;
@property (nonatomic) MBLCommand *command;
@property (nonatomic) MBLTestDebug *testDebug;
@property (nonatomic) MBLMacro *macro;

@property (nonatomic) MBLNonVolatileState *nonVolatileState;

@property (nonatomic) MBLDispatchQueue *zeroCountQueue;

// Properties needed internally requring AutoConding
@property (nonatomic) NSArray *modules;
@end


@implementation MBLMetaWear {
    // Ivars for internal things that arn't exposed anywhere as properties because they don't need encoded
    NSMutableArray<BFTaskCompletionSource *> *connectionSources;
    NSMutableArray<BFTaskCompletionSource *> *disconnectionSources;
    NSMutableArray<BFTaskCompletionSource *> *RSSISources;
    NSMutableArray<BFTaskCompletionSource *> *batteryLifeSources;
    NSMutableArray<BFTaskCompletionSource *> *deviceInfoSources;

    int characteristicCount;
    int serviceCount;
    int connectionRetryCount;

    MBLSimulationHandler simulatorHandler;
    MBLDataHandler snifferHandler;
    NSMutableDictionary *moduleInfoTaskSources;
    int commandCount;
    
    CBCharacteristic *metawearCommandCharacteristic;
    CBCharacteristic *metawearNotification6Characteristic;
    CBCharacteristic *batteryLifeCharacteristic;
    CBCharacteristic *disModelNumberCharacteristic;
    CBCharacteristic *disManufacturerNameCharacteristic;
    CBCharacteristic *disSerialNumberCharacteristic;
    CBCharacteristic *disHardwareRevisionCharacteristic;
    CBCharacteristic *disFirmwareRevisionCharacteristic;
    
    MBLFirmwareUpdateManager *updateManager;
    
    MBLDispatchQueue *simulatorCountQueue;
    NSMutableArray  *simulatorFreeTasks;
    BOOL simulatorBusy;
    NSObject *simulatorHandlerMutex;
}

// Properties that need custom encode/decode functions
@synthesize state = _noencode_state;
@synthesize isGuestConnection = _noencode_isGuestConnection;

@synthesize peripheral = _noencode_peripheral;
@synthesize bypassSetup = _noencode_bypassSetup;

@synthesize zeroCountQueue = _noencode_zeroCountQueue;

- (NSError *)writeToFile:(NSString *)filename
{
    MBLLog(MBLLogLevelInfo, @"Saving to disk: %@", self);
    NSData *data = [FastCoder dataWithRootObject:self];
    NSError *error = nil;
    
#if TARGET_OS_IOS || TARGET_OS_TV
    [data writeToFile:filename
              options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication
                error:&error];
#else
    [data writeToFile:filename
              options:NSDataWritingAtomic
                error:&error];
#endif
    
    if (error) { MBLLog(MBLLogLevelError, @"%@", error); }
    return error;
}

- (instancetype)initWithPeripheral:(id<MBLBluetoothPeripheral>)peripheral
              andAdvertisementData:(NSDictionary *)advertisementData
                           andRSSI:(NSNumber *)RSSI
{
    self = [super init];
    if (self) {
        peripheral.delegate = self;
        
        self.peripheral = peripheral;
        self.identifier = peripheral.identifier;
        self.nameImpl = peripheral.name;
        self.discoveryTimeRSSI = RSSI;
        
        self.state = MBLConnectionStateDisconnected;
        
        connectionSources = [NSMutableArray array];
        disconnectionSources = [NSMutableArray array];
        RSSISources = [NSMutableArray array];
        batteryLifeSources = [NSMutableArray array];
        deviceInfoSources = [NSMutableArray array];
        
        moduleInfoTaskSources = [NSMutableDictionary dictionary];
        
        self.zeroCountQueue = [[MBLDispatchQueue alloc] initWithName:@"com.mbientlab.metawear.zeroCountQueue"];
        simulatorCountQueue = [[MBLDispatchQueue alloc] initWithName:@"com.mbientlab.metawear.simulatorCountQueue"];
        simulatorFreeTasks = [NSMutableArray array];
        simulatorHandlerMutex = [[NSObject alloc] init];
        
        self.nonVolatileState = [[MBLNonVolatileState alloc] init];
    }
    return self;
}

- (id)awakeAfterFastCoding
{
    self.state = MBLConnectionStateDisconnected;
    
    connectionSources = [NSMutableArray array];
    disconnectionSources = [NSMutableArray array];
    RSSISources = [NSMutableArray array];
    batteryLifeSources = [NSMutableArray array];
    deviceInfoSources = [NSMutableArray array];
    
    moduleInfoTaskSources = [NSMutableDictionary dictionary];
    
    self.zeroCountQueue = [[MBLDispatchQueue alloc] initWithName:@"com.mbientlab.metawear.zeroCountQueue"];
    simulatorCountQueue = [[MBLDispatchQueue alloc] initWithName:@"com.mbientlab.metawear.simulatorCountQueue"];
    simulatorFreeTasks = [NSMutableArray array];
    simulatorHandlerMutex = [[NSObject alloc] init];
    
    return self;
}

- (void)setDiscoveryTimeRSSI:(NSNumber *)discoveryTimeRSSI
{
    // Reject erroneous values
    if (discoveryTimeRSSI.doubleValue > -15.0) {
        return;
    }
    _discoveryTimeRSSI = discoveryTimeRSSI;
    if (!self.rssiAverager) {
        self.rssiAverager = [[MBLMovingAverage alloc] initWithPeriod:4];
    }
    [self.rssiAverager addDatum:discoveryTimeRSSI];
    // We null out the average is 10 seconds pass without a reading
    // We do this on main thread because performSelector afterDelay isn't working on other threads
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rssiTimeout) object:nil];
        [self performSelector:@selector(rssiTimeout) withObject:nil afterDelay:10];
    });
}

- (NSNumber *)averageRSSI
{
    if (self.rssiAverager) {
        return [NSNumber numberWithDouble:self.rssiAverager.movingAverage];
    }
    return nil;
}

- (void)rssiTimeout
{
    self.rssiAverager = nil;
}

- (BOOL)isGuestConnection
{
    if (self.state != MBLConnectionStateConnected) {
        MBLLog(MBLLogLevelWarning, @"isGuestConnection not valid unless a connection is established");
    }
    return _noencode_isGuestConnection;
}

- (BFTask *)initializeModulesIfNeededAsync
{
    if (!self.modules) {
        // Start listening to the global notification register since the module init code
        // reads data and need callbacks throught this characteristic
        [self.peripheral setNotifyValue:YES forCharacteristic:metawearNotification6Characteristic];
        return [self resetModulesAsync];
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask<MBLModuleInfo *> *)readModuleInfo:(uint8_t)moduleId
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    @synchronized(moduleInfoTaskSources) {
        moduleInfoTaskSources[[NSNumber numberWithInt:moduleId]] = source;
    }
    
    // We expect a callback since this is a read
    [self incrementCount];
    uint8_t data[] = { moduleId, 0x80 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    // Ship the read!
    [self writeCommandRegister:[NSData dataWithBytes:data length:dataSize] withResponse:NO];
    return source.task;
}

- (BFTask *)resetModulesAsync
{
    assert(self.peripheral && self.peripheral.state == MBLConnectionStateConnected);
    uint32_t magicKey = self.testDebug.magicKey;
    
    return [[[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        self.modules = nil;
        self.mechanicalSwitch = nil;
        self.led = nil;
        self.accelerometer = nil;
        self.temperature = nil;
        self.gpio = nil;
        self.neopixel = nil;
        self.iBeacon = nil;
        self.hapticBuzzer = nil;
        self.dataProcessor = nil;
        self.command = nil;
        self.logging = nil;
        self.timer = nil;
        self.serial = nil;
        self.ancs = nil;
        self.macro = nil;
        self.conductance = nil;
        self.settings = nil;
        self.barometer = nil;
        self.gyro = nil;
        self.ambientLight = nil;
        self.magnetometer = nil;
        self.hygrometer = nil;
        self.photometer = nil;
        self.proximity = nil;
        self.testDebug = nil;
        
        self.configuration = nil;
        
        // Initialize the madness
        // These 3 must go first so that the other modules can access them duing init
        NSMutableArray *tasks = [NSMutableArray array];
        [tasks addObject:[[self readModuleInfo:0x9] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.dataProcessor = [MBLDataProcessor objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xB] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.logging = [MBLLogging objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xA] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.command = [MBLCommand objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        return [BFTask taskForCompletionOfAllTasks:tasks];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        NSMutableArray *tasks = [NSMutableArray array];
        [tasks addObject:[[self readModuleInfo:0x1] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.mechanicalSwitch = [MBLMechanicalSwitch objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x2] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.led = [MBLLED objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x3] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.accelerometer = [MBLAccelerometer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x4] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.temperature = [MBLTemperature objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x5] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.gpio = [MBLGPIO objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x6] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.neopixel = [MBLNeopixel objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x7] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.iBeacon = [MBLiBeacon objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x8] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.hapticBuzzer = [MBLHapticBuzzer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xE] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.ancs = [MBLANCS objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xC] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.timer = [MBLTimer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xD] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.serial = [MBLSerial objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xF] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.macro = [MBLMacro objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x10] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.conductance = [MBLConductance objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x11] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.settings = [MBLSettings objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x12] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.barometer = [MBLBarometer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x13] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.gyro = [MBLGyro objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x14] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.ambientLight = [MBLAmbientLight objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x15] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.magnetometer = [MBLMagnetometer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x16] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.hygrometer = [MBLHygrometer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x17] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.photometer = [MBLPhotometer objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0x18] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.proximity = [MBLProximity objectWithDevice:self moduleInfo:moduleInfo];
            }
        }]];
        [tasks addObject:[[self readModuleInfo:0xFE] successOnMetaWear:^(MBLModuleInfo *moduleInfo) {
            if (moduleInfo) {
                self.testDebug = [MBLTestDebug objectWithDevice:self moduleInfo:moduleInfo];
                self.testDebug.magicKey = magicKey;
            }
        }]];
        return [BFTask taskForCompletionOfAllTasks:tasks];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        // Note this order is very specific, the index must correspond to the module id
        self.modules = @[[NSNull null],
                         self.mechanicalSwitch ? self.mechanicalSwitch : [NSNull null],
                         self.led ? self.led : [NSNull null],
                         self.accelerometer ? self.accelerometer : [NSNull null],
                         self.temperature ? self.temperature : [NSNull null],
                         self.gpio ? self.gpio : [NSNull null],
                         self.neopixel ? self.neopixel : [NSNull null],
                         self.iBeacon ? self.iBeacon : [NSNull null],
                         self.hapticBuzzer ? self.hapticBuzzer : [NSNull null],
                         self.dataProcessor ? self.dataProcessor : [NSNull null],
                         self.command ? self.command : [NSNull null],
                         self.logging ? self.logging : [NSNull null],
                         self.timer ? self.timer : [NSNull null],
                         self.serial ? self.serial : [NSNull null],
                         self.ancs ? self.ancs : [NSNull null],
                         self.macro ? self.macro : [NSNull null],
                         self.conductance ? self.conductance : [NSNull null],
                         self.settings ? self.settings : [NSNull null],
                         self.barometer ? self.barometer : [NSNull null],
                         self.gyro ? self.gyro : [NSNull null],
                         self.ambientLight ? self.ambientLight : [NSNull null],
                         self.magnetometer ? self.magnetometer : [NSNull null],
                         self.hygrometer ? self.hygrometer : [NSNull null],
                         self.photometer ? self.photometer : [NSNull null],
                         self.proximity ? self.proximity : [NSNull null]];
        
        // Save this as the reset state of the device
        // Do this on the bleQueue so that we don't process events while the save state is happening
        NSString *filename = [[MBLMetaWearManager sharedManager] logFilename:[self.identifier.UUIDString stringByAppendingString:@"Reset"]];
        return [self writeToFile:filename];
    }];
}

- (void)copyModulesFrom:(MBLMetaWear *)other
{
    self.identifier = other.identifier;
    self.nameImpl = other.name;
    self.deviceInfo = other.deviceInfo;
    
    self.dataProcessor = other.dataProcessor;
    self.logging = other.logging;
    self.command = other.command;
    
    self.mechanicalSwitch = other.mechanicalSwitch;
    self.led = other.led;
    self.temperature = other.temperature;
    self.accelerometer = other.accelerometer;
    self.gpio = other.gpio;
    self.hapticBuzzer = other.hapticBuzzer;
    self.iBeacon = other.iBeacon;
    self.neopixel = other.neopixel;
    self.ancs = other.ancs;
    self.macro = other.macro;
    self.conductance = other.conductance;
    self.timer = other.timer;
    self.serial = other.serial;
    self.settings = other.settings;
    self.barometer = other.barometer;
    self.gyro = other.gyro;
    self.ambientLight = other.ambientLight;
    self.magnetometer = other.magnetometer;
    self.hygrometer = other.hygrometer;
    self.photometer = other.photometer;
    self.proximity = other.proximity;
    
    self.testDebug = other.testDebug;
    
    self.modules = other.modules;
    
    for (id obj in self.modules) {
        if ([obj isKindOfClass:[MBLModule class]]) {
            MBLModule *module = obj;
            module.device = self;
        }
    }
    self.testDebug.device = self;
    
    self.configuration = other.configuration;
}

- (void)showFastCodingWarnings:(id<MBLRestorable>)configuration
{
    if (configuration) {
        int unsigned numMethods;
        Method *methods = class_copyMethodList([configuration class], &numMethods);
        for (int i = 0; i < numMethods; i++) {
            NSString *methodName = NSStringFromSelector(method_getName(methods[i]));
            if ([methodName isEqualToString:@"encodeWithCoder:"] || [methodName isEqualToString:@"initWithCoder:"]) {
                MBLLog(MBLLogLevelWarning, @"[DEPRECATED] We use FastCoding (https://github.com/nicklockwood/FastCoding) so you no longer need to implement NSCoding yourself.  By default all properties are saved and restored.  Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them.");
                break;
            }
        }
        free(methods);
    }
}

- (BFTask *)setConfigurationAsync:(id<MBLRestorable>)configuration
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    assert(![MBLConstants isSimulatorQueue] && "Can't set a configuration within a programCommandsToRunOnEventAsync: block");
    dispatch_async([MBLConstants metaWearQueue], ^{
        if (self.state != MBLConnectionStateConnected) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorNotConnected
                                                userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before performing setConfiguartion:handler:."}]];
            return;
        }
        [self showFastCodingWarnings:configuration];
        // The reset file is no longer valid since we are re-programming the device
        [self removeResetFile];
        
        // When the disconnect occurs we know the device has been cleared and is ready for a fresh programming
        [[self waitForDisconnection] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            // Reconnect if we need to program the beast
            if (configuration) {
                [[[self connectAsync] success:^(id  _Nonnull result) {
                    self.configuration = configuration;
                    [self.macro programConfigurationWithHandler:^{
                        [self synchronizeResetFileAsync];
                        [[self synchronizeAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                            [source trySetResult:self];
                            return nil;
                        }];
                    }];
                }] failure:^(NSError * _Nonnull error) {
                    [source trySetError:error];
                }];
            } else {
                self.modules = nil;
                [[self synchronizeAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                    [source trySetResult:self];
                    return nil;
                }];
            }
            return nil;
        }];
        
        // Wipe the device!
        [self.macro clearAllMacros];
        [[[self.logging stopAndClearLog] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            NSString *curVersion = self.accelerometer.device.deviceInfo.firmwareRevision;
            // Older versions don't have a reliable reset UID
            if ([MBLConstants versionString:curVersion isLessThan:@"1.0.7"]) {
                self.modules = nil;
                [self synchronizeAsync];
            }
            return [self.testDebug resetDeviceAfterGarbageCollect];
        }] failure:^(NSError * _Nonnull error) {
            [source trySetError:error];
        }];
    });
    return source.task;
}

- (NSString *)name
{
    return self.nameImpl;
}

- (void)setName:(NSString *)name
{
    if (name.length > 8) {
        MBLLog(MBLLogLevelWarning, @"MetaWear advertising name truncated to 8 characters");
        self.nameImpl = [name substringToIndex:8];
    } else {
        self.nameImpl = name;
    }
    [self.settings.deviceName writeDataAsync:[self.nameImpl dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)updateName:(NSString *)name
{
    self.nameImpl = name;
}

- (BFTask *)connectAsync
{
    return [self connectWithTimeoutInternalAsync:nil];
}

- (BFTask *)connectWithTimeoutAsync:(NSTimeInterval)timeout
{
    return [self connectWithTimeoutInternalAsync:[NSNumber numberWithDouble:timeout]];
}

- (BFTask *)connectWithTimeoutInternalAsync:(NSNumber *)timeout
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        // Our next move depends on what state we are in now
        switch (self.state) {
            case MBLConnectionStateConnected:
                return [BFTask taskWithResult:nil];
            case MBLConnectionStateConnecting:
            case MBLConnectionStateDiscovery:
                return [self waitForConnectionWithTimeout:timeout];
            case MBLConnectionStateDisconnected:
            case MBLConnectionStateDisconnecting:
                self.state = MBLConnectionStateConnecting;
                BFTask *task = [self waitForConnectionWithTimeout:timeout];
                characteristicCount = 0;
                serviceCount = 0;
                connectionRetryCount = 2;
                [[MBLMetaWearManager sharedManager] connectMetaWear:self];
                return task;
        }
    }];
}

- (BFTask *)waitForConnectionWithTimeout:(NSNumber *)timeout
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    @synchronized(connectionSources) {
        [connectionSources addObject:taskSource];
    }
    if (timeout) {
        // We do this on main thread because performSelector afterDelay isn't working on other threads
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(connectionTimeout:) withObject:taskSource afterDelay:timeout.doubleValue];
        });
    }
    return taskSource.task;
}

- (void)connectionTimeout:(BFTaskCompletionSource *)source
{
    @synchronized(connectionSources) {
        // We'll handle this source right now!
        [connectionSources removeObject:source];
        // Set a timeout error
        [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                code:kMBLErrorConnectionTimeout
                                            userInfo:@{NSLocalizedDescriptionKey : @"Timeout during connection.  Make sure MetaWear is charged and within range."}]];
        
        // If we are the only connection listener then abort the connection entirely
        if (connectionSources.count == 0) {
            [self disconnectAsync];
        }
    }
}

- (void)invokeConnectionHandlers:(NSError *)error
{
    @synchronized(connectionSources) {
        for (BFTaskCompletionSource *source in connectionSources) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionTimeout:) object:source];
            });
            if (error) {
                [source trySetError:error];
            } else {
                [source trySetResult:self];
            }
        }
        [connectionSources removeAllObjects];
    }
}

- (BFTask *)disconnectAsync
{
    // Our next move depends on what state we are in now
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        switch (self.state) {
            case MBLConnectionStateConnected:
            {
                BFTask *task = [self waitForDisconnection];
                [[self waitForCommandCompletion] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                    self.state = MBLConnectionStateDisconnecting;
                    [[MBLMetaWearManager sharedManager] disconnectMetaWear:self fromPeripheralSide:YES];
                    return nil;
                }];
                return task;
            }
            case MBLConnectionStateConnecting:
            case MBLConnectionStateDiscovery:
            {
                self.state = MBLConnectionStateDisconnecting;
                BFTask *task = [self waitForDisconnection];
                [[self waitForCommandCompletion] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                    [[MBLMetaWearManager sharedManager] disconnectMetaWear:self fromPeripheralSide:NO];
                    return nil;
                }];
                return task;
            }
            case MBLConnectionStateDisconnecting:
                return [self waitForDisconnection];
            case MBLConnectionStateDisconnected:
                return [BFTask taskWithResult:nil];
        }
    }];
}

- (BFTask *)waitForDisconnection
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    @synchronized(disconnectionSources) {
        [disconnectionSources addObject:taskSource];
    }
    return taskSource.task;
}

- (void)invokeDisconnectionHandlers:(NSError *)error
{
    @synchronized(disconnectionSources) {
        for (BFTaskCompletionSource *source in disconnectionSources) {
            if (error) {
                [source trySetError:error];
            } else {
                [source trySetResult:self];
            }
        }
        [disconnectionSources removeAllObjects];
    }
}

- (void)rememberDevice
{
    [[MBLMetaWearManager sharedManager] rememberMetaWear:self];
}

- (void)forgetDevice
{
    [[MBLMetaWearManager sharedManager] forgetMetaWear:self];
}

- (BFTask *)synchronizeAsync
{
    NSString *filename = [[MBLMetaWearManager sharedManager] logFilename:self.identifier.UUIDString];
    // Do this on the metaWearQueue so that we don't modify any data while the save is happening
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        return [self writeToFile:filename];
    }];
}

- (BFTask *)synchronizeResetFileAsync
{
    NSString *filename = [[MBLMetaWearManager sharedManager] logFilename:[self.identifier.UUIDString stringByAppendingString:@"Reset"]];
    // Do this on the metaWearQueue so that we don't modify any data while the save is happening
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        return [self writeToFile:filename];
    }];
}

- (void)removeResetFile
{
    NSString *filename = [[MBLMetaWearManager sharedManager] logFilename:[self.identifier.UUIDString stringByAppendingString:@"Reset"]];
    // Remove the reset state
    dispatch_async([MBLConstants metaWearQueue], ^{
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
        if (!success) {
            if (!([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == 4)) {
                MBLLog(MBLLogLevelError, @"%@", error);
            }
        }
    });
}

- (void)didConnect
{
    dispatch_async([MBLConstants metaWearQueue], ^{
        // Only access state from the metaWearQueue
        self.state = MBLConnectionStateDiscovery;
        [self.peripheral discoverServices:@[[MBLConstants serviceUUID],
                                            [MBLConstants batteryServiceUUID],
                                            [MBLConstants DISServiceUUID],
                                            [MBLConstants DFUServiceUUID]]];
    });
}

- (void)didDisconnect:(NSError *)error
{
    MBLConnectionState __block prevState;
    [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        prevState = self.state;
        // Clean up everything
        self.peripheral = nil;
        self.state = MBLConnectionStateDisconnected;
        metawearCommandCharacteristic = nil;
        metawearNotification6Characteristic = nil;
        batteryLifeCharacteristic = nil;
        disManufacturerNameCharacteristic = nil;
        disSerialNumberCharacteristic = nil;
        disHardwareRevisionCharacteristic = nil;
        disFirmwareRevisionCharacteristic = nil;
        disModelNumberCharacteristic = nil;
        
        // Inform all the modules of this disconnection
        for (id obj in self.modules) {
            if ([obj isKindOfClass:[MBLModule class]]) {
                MBLModule *module = obj;
                [module deviceDisconnected:error];
            }
        }
        [self.testDebug deviceDisconnected:error];
        
        // On disconnect we cant expect to get past reads back right, so clear out everything
        [self.zeroCountQueue reset];
        [simulatorCountQueue reset];
        simulatorBusy = NO;
        simulatorFreeTasks = [NSMutableArray array];
        
        // Persist the current state to disk
        return [self synchronizeAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        // Make sure all the connection handlers are flushed out
        NSError *connectionError = error;
        switch (prevState) {
            case MBLConnectionStateConnecting:
            case MBLConnectionStateDiscovery:
                if (!connectionError) {
                    connectionError = [NSError errorWithDomain:kMBLErrorDomain
                                                          code:kMBLErrorUnexpectedDisconnect
                                                      userInfo:@{NSLocalizedDescriptionKey : @"Unexpected disconnect during connection.  Please try connection again."}];
                }
                [self connectionCompleteWithError:connectionError];
                break;
            case MBLConnectionStateDisconnecting:
                if (!connectionError) {
                    connectionError = [NSError errorWithDomain:kMBLErrorDomain
                                                          code:kMBLErrorDisconnectRequested
                                                      userInfo:@{NSLocalizedDescriptionKey : @"Disconnect requested while a connection was in progress.  Please try connection again."}];
                }
                [self invokeConnectionHandlers:connectionError];
                break;
            default:
                break;
        }
        
        // And flush out all the disconnection handlers
        [self invokeDisconnectionHandlers:error];
        return nil;
    }];
}

- (void)bluetoothPoweredOff
{
    MBLLog(MBLLogLevelInfo, @"bluetoothPoweredOff");
    connectionRetryCount = 0;
    [self didDisconnect:[NSError errorWithDomain:kMBLErrorDomain
                                            code:kMBLErrorBluetoothPoweredOff
                                        userInfo:@{NSLocalizedDescriptionKey : @"Core Bluetooth Error.  Please ensure bluetooth is enabled."}]];
}

- (void)writeCommandRegister:(NSData *)data withResponse:(BOOL)withResponse
{
    if (data.length > 20) {
        [NSException raise:@"ERROR" format:@"Trying to write more than 20 bytes to BLE characteristic"];
    }
    
    if (simulatorHandler && [MBLConstants isSimulatorQueue]) {
        MBLLog(MBLLogLevelInfo, @"Simulating: %@", data);
        simulatorHandler(*(uint8_t *)data.bytes, *(uint8_t *)(data.bytes + 1), [data subdataWithRange:NSMakeRange(2, data.length - 2)]);
        return;
    }
    if (snifferHandler) {
        snifferHandler(data, nil);
    }
    
    CBCharacteristicWriteType type = withResponse ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse;
    // In old firmware we couldn't write without response
    if (!(metawearCommandCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)) {
        type = CBCharacteristicWriteWithResponse;
    }
    // Throttle by having every Nth request wait for response
    if (++commandCount == MAX_PENDING_WRITES) {
        commandCount = 0;
        type = CBCharacteristicWriteWithResponse;
    }
    MBLLog(MBLLogLevelInfo, @"%@Writing: %@ %@", snifferHandler ? @"Sniff " : @"", data, type == CBCharacteristicWriteWithResponse ? @"RSP": @"NO-RSP");
    if (self.peripheral && metawearCommandCharacteristic) {
        [self.peripheral writeValue:data
                  forCharacteristic:metawearCommandCharacteristic
                               type:type];
    }
}

- (void)startSimulationWithHandler:(MBLSimulationHandler)handler
{
    @synchronized(simulatorHandlerMutex) {
        assert(!simulatorHandler && "Nesting Simulation?");
        simulatorHandler = handler;
    }
}

- (void)stopSimulation
{
    @synchronized(simulatorHandlerMutex) {
        simulatorHandler = nil;
        BFTaskCompletionSource *souce = [simulatorFreeTasks firstObject];
        if (souce) {
            [simulatorFreeTasks removeObjectAtIndex:0];
            [souce trySetResult:nil];
        } else {
            simulatorBusy = NO;
        }
    }
}

- (void)startSnifferWithHandler:(MBLDataHandler)handler
{
    snifferHandler = handler;
}
- (void)stopSniffer
{
    snifferHandler = nil;
}

- (void)incrementCount
{
    if ([MBLConstants isSimulatorQueue]) {
        MBLLog(MBLLogLevelDebug, @"+1 SimulatorQueue");
        [simulatorCountQueue suspend];
    } else {
        MBLLog(MBLLogLevelDebug, @"+1 CountQueue");
        BOOL wasSuspended = [self.zeroCountQueue suspend];
        // If we were not previously suspended that means the link was
        // idle, and since we are in this function work is about to happen
        // so add a handler here to watch for when all activity is complete.
        // At that point we reset the command count and update the cache
        if (!wasSuspended) {
            [self.zeroCountQueue addOperationWithBlock:^{
                commandCount = 0;
                [self synchronizeAsync];
            }];
        }
    }
}

- (void)decrementCount
{
    if ([MBLConstants isSimulatorQueue]) {
        MBLLog(MBLLogLevelDebug, @"-1 SimulatorQueue");
        [simulatorCountQueue resume];
    } else {
        MBLLog(MBLLogLevelDebug, @"-1 CountQueue");
        [self.zeroCountQueue resume];
    }
}

- (BFTask *)waitForCommandCompletion
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [self.zeroCountQueue addOperationWithBlock:^{
        [source trySetResult:nil];
    }];
    return source.task;
}

- (BFTask *)waitForSimulatorCompletion
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [simulatorCountQueue addOperationWithBlock:^{
        [source trySetResult:nil];
    }];
    return source.task;
}

- (BFTask *)waitForSimulatorTurn
{
    @synchronized(simulatorHandlerMutex) {
        if (simulatorBusy) {
            BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
            [simulatorFreeTasks addObject:source];
            return source.task;
        } else {
            simulatorBusy = YES;
            return [BFTask taskWithResult:nil];
        }
    }
}

- (BFTask<NSNumber *> *)readRSSIAsync
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    dispatch_async([MBLConstants metaWearQueue], ^{
        if (self.state != MBLConnectionStateConnected) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                   code:kMBLErrorNotConnected
                                               userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before reading RSSI."}]];
        } else {
            [self.peripheral readRSSI];
        }
    });
    @synchronized (RSSISources) {
        [RSSISources addObject:source];
    }
    return source.task;
}

- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error
{
    @synchronized(RSSISources) {
        for (BFTaskCompletionSource *source in RSSISources) {
            if (error) {
                [source trySetError:error];
            } else {
                [source trySetResult:RSSI];
            }
        }
        [RSSISources removeAllObjects];
    }
}


- (BFTask<NSNumber *> *)readBatteryLifeAsync
{
    if (!batteryLifeCharacteristic) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorNotConnected
                                                     userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before reading battery life."}]];
    }
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    @synchronized (batteryLifeSources) {
        [batteryLifeSources addObject:source];
    }
    [self.peripheral readValueForCharacteristic:batteryLifeCharacteristic];
    return source.task;
}

- (BFTask<MBLDeviceInfo *> *)readDeviceInfoAsync;
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    @synchronized (deviceInfoSources) {
        [deviceInfoSources addObject:source];
    }
    if (self.deviceInfoReady) {
        // If we have it deviceInfo cached just check the firmware rev to
        // make sure the user didn't update using a different iOS device.
        [self.peripheral readValueForCharacteristic:disFirmwareRevisionCharacteristic];
    } else {
        self.deviceInfo = [[MBLDeviceInfo alloc] init];
        
        [self.peripheral readValueForCharacteristic:disManufacturerNameCharacteristic];
        [self.peripheral readValueForCharacteristic:disSerialNumberCharacteristic];
        [self.peripheral readValueForCharacteristic:disHardwareRevisionCharacteristic];
        [self.peripheral readValueForCharacteristic:disFirmwareRevisionCharacteristic];
        if (disModelNumberCharacteristic) {
            [self.peripheral readValueForCharacteristic:disModelNumberCharacteristic];
        }
    }
    return source.task;
}

- (BOOL)loadResetState
{
    // Set this object back to the reset state if it exists
    NSString *resetFile = [[MBLMetaWearManager sharedManager] logFilename:[self.identifier.UUIDString stringByAppendingString:@"Reset"]];
    //MBLMetaWear *savedState = [MBLMetaWear objectWithContentsOfFile:resetFile];
    //load fast archive
    NSData *data = [NSData dataWithContentsOfFile:resetFile];
    //parse fast archive
    MBLMetaWear *savedState = [FastCoder objectWithData:data];
    
    if (savedState) {
        MBLLog(MBLLogLevelInfo, @"Loaded Reset State");
        [self copyModulesFrom:savedState];
    }
    return savedState != nil;
}

- (void)resetDevice
{
    NSString *curVersion = self.accelerometer.device.deviceInfo.firmwareRevision;
    if ([MBLConstants versionString:curVersion isLessThan:@"1.0.7"]) {
        if (![self loadResetState]) {
            // If no reset state, just null the module pointer which triggers a re-discovery
            self.modules = nil;
            [self synchronizeAsync];
        }
    }
    // Trigger the reset, this will cause a disconnect
    [self.testDebug resetDevice];
}

- (BFTask<NSNumber *> *)checkForFirmwareUpdateAsync
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [[[MBLFirmwareUpdateManager getLatestFirmwareForDeviceAsync:self.deviceInfo] successOnMetaWear:^(MBLFirmwareBuild * _Nonnull result) {
        if ([MBLConstants versionString:self.deviceInfo.firmwareRevision isLessThan:result.firmwareRev]) {
            [source trySetResult:@YES];
        } else {
            [source trySetResult:@NO];
        }
    }] failureOnMetaWear:^(NSError * _Nonnull error) {
        [source trySetError:error];
    }];
    return source.task;
}

- (BFTask<MBLFirmwareUpdateInfo *> *)startUpdate
{
    return [[updateManager startUpdate] continueOnMetaWearWithBlock:^id _Nullable(BFTask<MBLFirmwareUpdateInfo *> * _Nonnull t) {
        updateManager = nil;
        if (t.error) {
            [[MBLAnalytics sharedManager] postEventForDevice:self.identifier
                                               eventCategory:[@"update " stringByAppendingString:kMBLAPIVersion]
                                                 eventAction:@"fail"
                                                  eventLabel:t.error.localizedDescription];
        } else {
            // Post update success to the analytics engine
            [[MBLAnalytics sharedManager] postEventForDevice:self.identifier
                                               eventCategory:[@"update " stringByAppendingString:kMBLAPIVersion]
                                                 eventAction:@"success"
                                                  eventLabel:@""];
            
            // Clean out the old modules so that the connect will trigger a re-discovery
            self.modules = nil;
            // This is the one time nonVolatileState is cleared
            self.nonVolatileState = [[MBLNonVolatileState alloc] init];
            [self synchronizeAsync];
            // TODO: Reprogram device after update if we have a configuration
        }
        return t;
    }];
}

- (BFTask *)prepareForFirmwareUpdateToVersionAsync:(MBLFirmwareBuild *)firmware
{
    // Create master class which handles all the details for the firmware upate process
    updateManager = [[MBLFirmwareUpdateManager alloc] initWithFirmware:firmware
                                                            identifier:self.peripheral.identifier];
    
    return [[[[MBLFirmwareUpdateManager isFirmwareReachableAsync] continueOnMetaWearWithSuccessBlock:^id (BFTask<NSNumber *> *t) {
        // We must connect then jump to the bootloader.  This special flag
        // removes most of the init flow incase we connect to a super old
        // unsuported firmware version.
        self.bypassSetup = YES;
        return [self connectAsync];
    }] continueOnMetaWearWithBlock:^id (BFTask *t) {
        // Make sure to always turn off the flag
        self.bypassSetup = NO;
        // Its possible we are already in DFU, so gracefully handle that condition
        BOOL alreadyInDFU = [t.error.domain isEqualToString:kMBLErrorDomain] && t.error.code == kMBLErrorDFUServiceFound;
        // Forwared errors we can't handle
        if (!alreadyInDFU && t.error) {
            return t;
        }
        // Getting into DFU causes the device to disconnect, so we execute this
        // async to make sure our disconnection handler gets registered first.
        dispatch_async([MBLConstants metaWearQueue], ^{
            if (alreadyInDFU) {
                // See to simulate the disconnect that occurs when we jump to bootloader
                [[MBLMetaWearManager sharedManager] disconnectMetaWear:self fromPeripheralSide:NO];
            } else {
                [self.testDebug jumpToBootloader];
            }
        });
        return [self waitForDisconnection];
    }] continueOnMetaWearWithSuccessBlock:^id (BFTask *t) {
        return [self startUpdate];
    }];
}

- (BFTask<MBLFirmwareUpdateInfo *> *)prepareForFirmwareUpdateAsync
{
    return [self prepareForFirmwareUpdateToVersionAsync:nil];
}

- (void)simulateDisconnect
{
    [[MBLMetaWearManager sharedManager] disconnectMetaWear:self fromPeripheralSide:YES];
}


- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didDiscoverServices:(NSError *)error
{
    MBLLog(MBLLogLevelInfo, @"didDiscoverServices");
    if (error) {
        [self connectionCompleteWithError:error];
        return;
    }
    
    int services = 0;
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[MBLConstants serviceUUID]]) {
            services++;
            [peripheral discoverCharacteristics:@[[MBLConstants commandUUID], [MBLConstants notificationUUID]] forService:service];
        } else if ([service.UUID isEqual:[MBLConstants batteryServiceUUID]]) {
            services++;
            [peripheral discoverCharacteristics:@[[MBLConstants batteryLifeUUID]] forService:service];
        } else if ([service.UUID isEqual:[MBLConstants DISServiceUUID]]) {
            services++;
            [peripheral discoverCharacteristics:@[[MBLConstants DISManufacturerNameUUID],
                                                  [MBLConstants DISSerialNumberUUID],
                                                  [MBLConstants DISHardwareRevUUID],
                                                  [MBLConstants DISFirmwareRevUUID],
                                                  [MBLConstants DISModelNumberUUID]] forService:service];
        } else if ([service.UUID isEqual:[MBLConstants DFUServiceUUID]]) {
            [self connectionCompleteWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                                  code:kMBLErrorDFUServiceFound
                                                              userInfo:@{NSLocalizedDescriptionKey : @"MetaWear device in bootloader mode.  Please update the firmware using prepareForFirmwareUpdateWithHandler:."}]];
            return;
        } else {
            [self connectionCompleteWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                                  code:kMBLErrorUnexpectedServices
                                                              userInfo:@{NSLocalizedDescriptionKey : @"MetaWear device contained an unexpected BLE service.  Please try connection again."}]];
            return;
        }
    }
    if (services != 3) {
        if (peripheral.services.count != 3) {
            [self connectionCompleteWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                                  code:kMBLErrorUnexpectedServices
                                                              userInfo:@{NSLocalizedDescriptionKey : @"Couldn't find all expected BLE services.  Please try connection again."}]];
        }
    }
}

- (void)unexpectedCharacteristic
{
    [self connectionCompleteWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                          code:kMBLErrorUnexpectedCharacteristics
                                                      userInfo:@{NSLocalizedDescriptionKey : @"MetaWear device contained an unexpected BLE characteristic.  Please try connection again."}]];
}

- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    MBLLog(MBLLogLevelInfo, @"didDiscoverCharacteristicsForService: %@", service.UUID);
    if (error) {
        [self connectionCompleteWithError:error];
        return;
    }
    
    characteristicCount += (int)service.characteristics.count;
    serviceCount++;
    
    if ([service.UUID isEqual:[MBLConstants serviceUUID]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[MBLConstants commandUUID]]) {
                metawearCommandCharacteristic = characteristic;
            } else if ([characteristic.UUID isEqual:[MBLConstants notificationUUID]]) {
                // Make sure we don't start getting an bunch of random data on connect
                // if the last disconnect wasn't so smooth
                [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                metawearNotification6Characteristic = characteristic;
            } else {
                [self unexpectedCharacteristic];
            }
        }
    } else if ([service.UUID isEqual:[MBLConstants batteryServiceUUID]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[MBLConstants batteryLifeUUID]]) {
                batteryLifeCharacteristic = characteristic;
            } else {
                [self unexpectedCharacteristic];
            }
        }
    } else if ([service.UUID isEqual:[MBLConstants DISServiceUUID]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[MBLConstants DISManufacturerNameUUID]]) {
                disManufacturerNameCharacteristic = characteristic;
            } else if ([characteristic.UUID isEqual:[MBLConstants DISSerialNumberUUID]]) {
                disSerialNumberCharacteristic = characteristic;
            } else if ([characteristic.UUID isEqual:[MBLConstants DISHardwareRevUUID]]) {
                disHardwareRevisionCharacteristic = characteristic;
            } else if ([characteristic.UUID isEqual:[MBLConstants DISFirmwareRevUUID]]) {
                disFirmwareRevisionCharacteristic = characteristic;
            } else if ([characteristic.UUID isEqual:[MBLConstants DISModelNumberUUID]]) {
                disModelNumberCharacteristic = characteristic;
            } else {
                [self unexpectedCharacteristic];
            }
        }
    }
    
    if (serviceCount == 3) {
        if (!(characteristicCount == 7 || characteristicCount == 8)) {
            [self connectionCompleteWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                                  code:kMBLErrorUnexpectedCharacteristics
                                                              userInfo:@{NSLocalizedDescriptionKey : @"MetaWear device contained an unexpected number of BLE characteristics.  Please try connection again."}]];
        } else {
            // Short circut if asked for
            if (self.bypassSetup) {
                // We need this one module to issue jump to bootloader commands
                self.testDebug = [MBLTestDebug objectWithDevice:self moduleInfo:[[MBLModuleInfo alloc] initWithId:0xFE data:nil]];
                [self.peripheral setNotifyValue:YES forCharacteristic:metawearNotification6Characteristic];
                [self connectionCompleteWithError:nil];
            } else {
                [self setupMetaWear];
            }
        }
    }
}


- (void)setupMetaWear
{
    [[[[[[[self readDeviceInfoAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<MBLDeviceInfo *> * _Nonnull t) {
        // Starting firmware 1.1.0 we can flood the beast!
        if ([MBLConstants versionString:t.result.firmwareRevision isLessThan:@"1.1.0"]) {
            MAX_PENDING_WRITES = 3;
        }
        // Make sure the firmware isn't too old
        NSString *required = MBLFirmwareVersionString([MBLMetaWearManager sharedManager].minimumRequiredVersion);
        if ([MBLConstants versionString:t.result.firmwareRevision isLessThan:required]) {
            // No sense to retry connection
            connectionRetryCount = 0;
            return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                             code:kMBLErrorOutdatedFirmware
                                                         userInfo:@{NSLocalizedDescriptionKey : @"Firmware update required before MetaWear can be used."}]];
        }
        // Setup all the modules if required (that would be if we haven't done a discovery yet)
        return [self initializeModulesIfNeededAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<MBLDeviceInfo *> * _Nonnull t) {
        // Start listening to the global notification register since the following
        // checks need to read data (which uses callbacks throught this characteristic)
        [self.peripheral setNotifyValue:YES forCharacteristic:metawearNotification6Characteristic];
        // 
        return [self.testDebug isGuestApplicationAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        self.isGuestConnection = t.result.boolValue;
        if (t.result.boolValue) {
            // If we are just a guest finish the connection now, note this will
            // jump over all "success" blocks
            return [BFTask cancelledTask];
        } else {
            // If we are the owning application do extra cleanup and state checking.
            // First check if the device happened to reset while we were away and if
            // so reload its reset state
            return [self.logging checkForResetAsync];
        }
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        BOOL didReset = t.result.boolValue;
        if (didReset) {
            if (![self loadResetState]) {
                // No saved reset state so dont' even bother sanity checking it
                return @NO;
            }
        }
        // Sanity check the state to see if it's valid
        return [self sanityCheck];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        BOOL stateValid = t.result.boolValue;
        if (!stateValid) {
            MBLLog(MBLLogLevelInfo, @"Unexpected MetaWear state - reseting modules");
            return [self resetModulesAsync];
        }
        return nil;
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        [self connectionCompleteWithError:t.error];
        return nil;
    }];
}

- (BFTask<NSNumber *> *)sanityCheck
{
    assert(!_noencode_isGuestConnection);
    // Perform some sanity checks on all the module state
    NSMutableArray *tasks = [NSMutableArray array];
    for (id obj in self.modules) {
        if ([obj isKindOfClass:[MBLModule class]]) {
            [tasks addObject:[obj isStateValid]];
        }
    };
    return [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        // Check for YES's
        BOOL allValid = YES;
        for (NSArray *array in task.result) {
            for (NSNumber *isValid in array) {
                if (!isValid.boolValue) {
                    allValid = NO;
                    break;
                }
            }
        }
        return [NSNumber numberWithBool:allValid];
    }];
}


-(void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
#ifdef DEBUG
    if (error) { MBLLog(MBLLogLevelError, @"didUpdateValueForCharacteristic Error: %@", error); }
    if (characteristic == metawearNotification6Characteristic) {
        MBLLog(MBLLogLevelInfo, @"Received: %@ ", characteristic.value);
    } else {
        MBLLog(MBLLogLevelInfo, @"didUpdateValueForCharacteristic = %@ with value %@",characteristic.UUID, characteristic.value);
    }
#endif
    if (characteristic == metawearCommandCharacteristic || characteristic == metawearNotification6Characteristic) {
        assert(characteristic.value.length);
        if (!characteristic.value.length) {
            return;
        }
        uint8_t moduleId = *(uint8_t *)characteristic.value.bytes;
        @synchronized(moduleInfoTaskSources) {
            BFTaskCompletionSource *source = moduleInfoTaskSources[[NSNumber numberWithInt:moduleId]];
            if (source) {
                [moduleInfoTaskSources removeObjectForKey:[NSNumber numberWithInt:moduleId]];
                if (error) {
                    [source trySetError:error];
                } else if (characteristic.value.length >= 4) {
                    // 4 or more bytes indicates the module is present and active
                    [source trySetResult:[[MBLModuleInfo alloc] initWithId:moduleId data:characteristic.value]];
                } else {
                    // Otherwise no module, so don't initialize it
                    [source trySetResult:nil];
                }
                [self decrementCount];
            } else if (moduleId < self.modules.count) {
                id module = self.modules[moduleId];
                if ([module respondsToSelector:@selector(recievedData:error:)]) {
                    [module recievedData:characteristic.value error:error];
                } else {
                    assert(NO && "No module found");
                }
            } else if (moduleId == self.testDebug.moduleInfo.moduleId) {
                if ([self.testDebug respondsToSelector:@selector(recievedData:error:)]) {
                    [self.testDebug recievedData:characteristic.value error:error];
                } else {
                    assert(NO && "No testDebug module found");
                }
            }
        }
    } else if (characteristic == batteryLifeCharacteristic) {
        @synchronized(batteryLifeSources) {
            for (BFTaskCompletionSource *source in batteryLifeSources) {
                if (error) {
                    [source trySetError:error];
                } else {
                    [source trySetResult:[NSNumber numberWithInt:*(uint8_t *)characteristic.value.bytes]];
                }
            }
            [batteryLifeSources removeAllObjects];
        }
    } else if (characteristic == disManufacturerNameCharacteristic) {
        self.deviceInfo.manufacturerName = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                                    length:characteristic.value.length
                                                                  encoding:NSASCIIStringEncoding];
        [self sendDeviceInfoIfReadyWithError:error];
    } else if (characteristic == disSerialNumberCharacteristic) {
        self.deviceInfo.serialNumber = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                                length:characteristic.value.length
                                                              encoding:NSASCIIStringEncoding];
        [self sendDeviceInfoIfReadyWithError:error];
    } else if (characteristic == disHardwareRevisionCharacteristic) {
        self.deviceInfo.hardwareRevision = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                                    length:characteristic.value.length
                                                                  encoding:NSASCIIStringEncoding];
        [self sendDeviceInfoIfReadyWithError:error];
    } else if (characteristic == disFirmwareRevisionCharacteristic) {
        NSString *firmwareRevision = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                              length:characteristic.value.length
                                                            encoding:NSASCIIStringEncoding];
        if (self.deviceInfo.firmwareRevision) {
            if (![self.deviceInfo.firmwareRevision isEqualToString:firmwareRevision]) {
                [self removeResetFile];
                // The firmware version changed, need to force a re-discovery
                self.modules = nil;
                [self synchronizeAsync];
            }
        }
        self.deviceInfo.firmwareRevision = firmwareRevision;
        [self sendDeviceInfoIfReadyWithError:error];
    } else if (characteristic == disModelNumberCharacteristic) {
        self.deviceInfo.modelNumber = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                               length:characteristic.value.length
                                                             encoding:NSASCIIStringEncoding];
        [self sendDeviceInfoIfReadyWithError:error];
    }
}

- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) { MBLLog(MBLLogLevelError, @"didWriteValueForCharacteristic Error: %@", error); }
}

- (BOOL)deviceInfoReady
{
    if (self.deviceInfo.manufacturerName &&
        self.deviceInfo.serialNumber &&
        self.deviceInfo.hardwareRevision &&
        self.deviceInfo.firmwareRevision &&
        (!disModelNumberCharacteristic || self.deviceInfo.modelNumber)) {
        return YES;
    }
    return NO;
}

- (void)sendDeviceInfoIfReadyWithError:(NSError *)error
{
    if (error || self.deviceInfoReady) {
        @synchronized(deviceInfoSources) {
            for (BFTaskCompletionSource *source in deviceInfoSources) {
                if (error) {
                    [source trySetError:error];
                } else {
                    [source trySetResult:self.deviceInfo];
                }
            }
            [deviceInfoSources removeAllObjects];
        }
    }
}

- (BOOL)retryConnectionIfAllowed
{
    if (connectionRetryCount) {
        [[MBLAnalytics sharedManager] postEventForDevice:self.identifier
                                           eventCategory:[@"connect " stringByAppendingString:kMBLAPIVersion]
                                             eventAction:@"retry"
                                              eventLabel:@""];
        MBLLog(MBLLogLevelInfo, @"Connection Failed -- Retrying");
        connectionRetryCount--;
        characteristicCount = 0;
        serviceCount = 0;
        self.peripheral = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[MBLMetaWearManager sharedManager] connectMetaWear:self];
        });
        return YES;
    }
    return NO;
}

- (void)connectionCompleteWithError:(NSError *)error
{
    if (error) {
        [[self disconnectAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if (![self retryConnectionIfAllowed]) {
                [[MBLAnalytics sharedManager] postEventForDevice:self.identifier
                                                   eventCategory:[@"connect " stringByAppendingString:kMBLAPIVersion]
                                                     eventAction:@"fail"
                                                      eventLabel:error.localizedDescription];
                MBLLog(MBLLogLevelInfo, @"Connection Failed");

                [self invokeConnectionHandlers:error];
            }
            return nil;
        }];
        return;
    }
    
    // Handle the passing case
    [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        // We set the state here so the deviceConnected handlers can
        // shut off any streams without errors about us not beging connected
        self.state = MBLConnectionStateConnected;
        // Inform all the modules of this connection
        NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:self.modules.count];
        for (id obj in self.modules) {
            if ([obj isKindOfClass:[MBLModule class]]) {
                MBLModule *module = obj;
                [tasks addObject:[module deviceConnected]];
            }
        }
        [tasks addObject:[self.testDebug deviceConnected]];
        return [BFTask taskForCompletionOfAllTasks:tasks];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        assert(!t.error);
        MBLLog(MBLLogLevelInfo, @"Connection Success %@", self.deviceInfo.firmwareRevision);
        [[MBLAnalytics sharedManager] postEventForDevice:self.identifier
                                           eventCategory:[@"connect " stringByAppendingString:kMBLAPIVersion]
                                             eventAction:@"success"
                                              eventLabel:self.deviceInfo.firmwareRevision];
        [self invokeConnectionHandlers:nil];
        return nil;
    }];
}


// Deprecated

- (void)connectWithTimeout:(NSTimeInterval)timeout handler:(MBLErrorHandler)handler
{
    [[self connectWithTimeoutAsync:timeout] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler(t.error);
        }
        return nil;
    }];
}

- (void)disconnectWithHandler:(MBLErrorHandler)handler
{
    [[self disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler(t.error);
        }
        return nil;
    }];
}

- (void)connectWithHandler:(MBLErrorHandler)handler
{
    [[self connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler(t.error);
        }
        return nil;
    }];
}

- (void)readBatteryLifeWithHandler:(MBLNumberHandler)handler
{
    [[self readBatteryLifeAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler(t.result, t.error);
        }
        return nil;
    }];
}

- (void)readRSSIWithHandler:(MBLNumberHandler)handler
{
    [[self readRSSIAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler(t.result, t.error);
        }
        return nil;
    }];
}

- (void)checkForFirmwareUpdateWithHandler:(MBLBoolHandler)handler
{
    [[self checkForFirmwareUpdateAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler([t.result boolValue], t.error);
        }
        return nil;
    }];
}

- (void)setConfiguration:(id<MBLRestorable>)configuration handler:(MBLErrorHandler)handler
{
    [[self setConfigurationAsync:configuration] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            handler(t.error);
        }
        return nil;
    }];
}

- (void)prepareForFirmwareUpdateWithHandler:(MBLFirmwareUpdateHandler)handler
{
    [[self prepareForFirmwareUpdateAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (handler) {
            MBLFirmwareUpdateInfo *info = t.result;
            handler(info.firmwareUrl, info.target, info.centralManager, t.error);
        }
        return nil;
    }];
}

- (void)updateFirmwareWithHandler:(MBLErrorHandler)handler
                  progressHandler:(MBLFloatHandler)progressHandler
{
    MBLLog(MBLLogLevelError, @"This function no longer works, use prepareForFirmwareUpdateWithHandler: instead");
}

- (void)synchronize
{
    [self synchronizeAsync];
}

@end
