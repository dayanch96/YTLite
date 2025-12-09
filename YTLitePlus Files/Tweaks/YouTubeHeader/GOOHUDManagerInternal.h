#import <Foundation/NSObject.h>
#import "YTHUDMessage.h"

@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(YTHUDMessage *)message;
+ (instancetype)sharedInstance;
@end