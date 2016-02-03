//
// Created by Alex Manarpies on 12/17/14.
//

#import "MovingAverage.h"


@interface MovingAverage ()

@property(nonatomic, strong) NSMutableArray *queue;
@property(nonatomic) NSUInteger period;
@property(nonatomic) NSUInteger count;

@property(nonatomic, readwrite) double movingAverage;
@property(nonatomic, readwrite) double cumulativeAverage;

@end

@implementation MovingAverage

- (instancetype)initWithPeriod:(NSUInteger)period {
    self = [self init];
    if (self) {
        _period = period;
        _queue = [[NSMutableArray alloc] initWithCapacity:period];
    }
    return self;
}

- (void)addDatum:(NSNumber *)datum {
    [self.queue insertObject:datum atIndex:0];

    double removed = 0;
    double datumd = [datum doubleValue];

    if (self.queue.count > self.period) {
        removed = [[self.queue lastObject] doubleValue];
        [self.queue removeLastObject];
    }

    self.movingAverage = self.movingAverage - (removed / self.period) + (datumd / self.period);
    self.cumulativeAverage = self.cumulativeAverage + (datumd - self.cumulativeAverage) / ++self.count;
}

@end