#import <Foundation/NSObject.h>

@interface MDXScreenDiscoveryManager : NSObject\
+ (instancetype)sharedInstance;
+ (void)setSharedInstance:(MDXScreenDiscoveryManager *)instance;
@end
