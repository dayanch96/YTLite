#import "MLCaptionSegment.h"
#import "YTInterval.h"

@interface MLCaption : YTInterval
- (NSUInteger)ID;
- (CGFloat)startTime;
- (CGFloat)endTime;
- (NSArray <MLCaptionSegment *> *)segments;
@end
