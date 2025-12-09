#import <Foundation/NSObject.h>

@interface MLPlayerEventCenter : NSObject
- (void)broadcastRateChange:(float)rate;
@end
