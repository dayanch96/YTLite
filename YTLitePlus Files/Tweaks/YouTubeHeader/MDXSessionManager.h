#import <Foundation/NSObject.h>

@interface MDXSessionManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)hasActiveMDXOrAirPlaySession;
@end
