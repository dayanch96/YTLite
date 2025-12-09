#import <Foundation/Foundation.h>

@protocol MLVideoFormatConstraint <NSObject>
- (int)videoQualitySetting;
- (int)stickyResolutionCap;
@end
