#import <CoreGraphics/CGBase.h>
#import "YTInterval.h"

@interface YTIntervalNode : NSObject
@property (nonatomic, strong, readwrite) YTInterval *value;
@property (nonatomic, assign, readwrite) NSInteger priority;
@property (nonatomic, assign, readwrite) CGFloat maxStop;
@property (nonatomic, assign, readwrite, getter=isMaxStopInclusive) BOOL maxStopInclusive;
@property (nonatomic, strong, readwrite) YTIntervalNode *left;
@property (nonatomic, strong, readwrite) YTIntervalNode *right;
- (void)enumerateAllIntervalsWithBlock:(void (^)(YTInterval *interval, BOOL *stop))block;
@end
