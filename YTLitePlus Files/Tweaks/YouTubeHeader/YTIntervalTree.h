#import <Foundation/NSSet.h>
#import "YTIntervalNode.h"

@interface YTIntervalTree : NSObject
- (YTIntervalNode *)root;
- (NSUInteger)count;
- (NSMutableSet <YTInterval *> *)allIntervals;
- (void)enumerateAllIntervalsWithBlock:(void (^)(YTInterval *interval))block;
@end
