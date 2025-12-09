#import <Foundation/Foundation.h>

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMClosedViewfinderController : NSObject

- (void)addClosedViewfinderReason:(NSInteger)reason;
- (void)removeClosedViewfinderReason:(NSInteger)reason;

@end
