//
//  MBLAccelerometerData.h
//  MetaWearApp
//
//  Created by Yu Suo on 7/22/14.
//  Copyright (c) 2014 Laura Kassovic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBLAccelerometerData : NSObject

@property (nonatomic) NSTimeInterval accDataInterval;
@property (nonatomic) double x, y, z;

@end
