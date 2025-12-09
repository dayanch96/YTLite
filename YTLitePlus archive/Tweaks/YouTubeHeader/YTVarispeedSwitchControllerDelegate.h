#import <CoreGraphics/CGGeometry.h>
#import <Foundation/NSObject.h>

@class YTVarispeedSwitchController;

@protocol YTVarispeedSwitchControllerDelegate <NSObject>
- (float)currentPlaybackRateForVarispeedSwitchController:(YTVarispeedSwitchController *)varispeedSwitchController;
- (void)varispeedSwitchController:(YTVarispeedSwitchController *)varispeedSwitchController didSelectRate:(float)playbackRate;
@end
