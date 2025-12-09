#import "GPBMessage.h"

@interface YTIModalClientThrottlingRules : GPBMessage
@property (nonatomic, readwrite, assign) BOOL oncePerTimeWindow;
@property (nonatomic, readwrite, assign) BOOL throttledAfterRecentSignIn;
@end
