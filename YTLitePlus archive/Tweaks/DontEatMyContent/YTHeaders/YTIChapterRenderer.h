#import "GPBMessage.h"
#import "YTIFormattedString.h"

@interface YTIChapterRenderer : GPBMessage
@property (nonatomic, readwrite, strong) YTIFormattedString *title;
@property (nonatomic, readwrite, assign) int timeRangeStartMillis;
@end
