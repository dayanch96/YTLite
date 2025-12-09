#import <Foundation/NSObject.h>

@interface YTNonCriticalStartupTelemetricSmartScheduler : NSObject
- (void)schedule:(int)identifier withBlock:(void (^)(void))block;
@end
