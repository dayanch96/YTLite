#import <CoreGraphics/CGBase.h>
#import <Foundation/NSObject.h>

@interface YTInterval : NSObject
- (CGFloat)start;
- (CGFloat)stop;
- (BOOL)startInclusive;
- (BOOL)stopInclusive;
@end
