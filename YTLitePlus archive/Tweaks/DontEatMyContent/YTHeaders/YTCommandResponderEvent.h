#import "YTICommand.h"

@interface YTCommandResponderEvent : NSObject
+ (instancetype)eventWithCommand:(YTICommand *)command entry:(id)entry sendClick:(BOOL)sendClick firstResponder:(id)firstResponder;
- (void)send;
@end
