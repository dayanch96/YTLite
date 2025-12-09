#import <Foundation/Foundation.h>

@interface GCKNNetworkReachability : NSObject
+ (instancetype)sharedInstance;
- (NSInteger)currentStatus;
@end
