//
// Created by Alex Manarpies on 12/17/14.
//

#import <Foundation/Foundation.h>


/**
* Utility class for maintaining a moving average over a given time period.
* Credits: http://stackoverflow.com/a/14740836/331283
*/
@interface MovingAverage : NSObject

@property(nonatomic, readonly) double movingAverage;
@property(nonatomic, readonly) double cumulativeAverage;

- (instancetype)initWithPeriod:(NSUInteger)period;

- (void)addDatum:(NSNumber *)datum;

@end