#import <Foundation/Foundation.h>

@interface MDXSessionManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)hasActiveMDXOrAirPlaySession;
@end
