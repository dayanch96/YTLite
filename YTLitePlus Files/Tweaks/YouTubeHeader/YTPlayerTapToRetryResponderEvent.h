#import "YTResponderEvent.h"

@interface YTPlayerTapToRetryResponderEvent : YTResponderEvent
+ (instancetype)eventWithFirstResponder:(id <YTResponder>)firstResponder;
@end
