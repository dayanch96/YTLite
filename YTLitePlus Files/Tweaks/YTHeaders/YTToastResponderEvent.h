#import <Foundation/Foundation.h>

@interface YTToastResponderEvent : NSObject
+ (instancetype)eventWithMessage:(NSString *)message firstResponder:(id)firstResponder;
- (void)send;
@end
