#import <Foundation/NSObject.h>

@protocol MLVideoFormatConstraint <NSObject>
- (int)videoQualitySetting;
- (int)stickyResolutionCap;
@end
