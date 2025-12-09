#import <Foundation/NSObject.h>

@interface GCKNNetworkReachability : NSObject
+ (instancetype)sharedInstance;
- (NSInteger)currentStatus;
@end
