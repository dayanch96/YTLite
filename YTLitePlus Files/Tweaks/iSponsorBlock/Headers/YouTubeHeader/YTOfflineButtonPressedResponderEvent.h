#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTOfflineButtonPressedResponderEvent : NSObject
+ (instancetype)eventWithOfflineVideoID:(NSString *)videoID fromView:(UIView *)view firstResponder:(id)firstResponder;
- (void)send;
@end