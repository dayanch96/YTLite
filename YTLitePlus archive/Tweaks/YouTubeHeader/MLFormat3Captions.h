#import "YTInterval.h"
#import "YTIntervalTree.h"

@interface MLFormat3Captions : YTInterval
- (YTIntervalTree *)windows;
- (YTIntervalTree *)implicitWindows;
- (YTIntervalTree *)captions;
@end
