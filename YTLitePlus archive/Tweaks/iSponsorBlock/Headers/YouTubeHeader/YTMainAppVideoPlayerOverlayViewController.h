#import "YTAdjustableAccessibilityProtocol.h"
#import "YTMainAppVideoPlayerOverlayView.h"
#import "YTResponder.h"
#import "YTVideoPlayerOverlayDelegate.h"

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController <YTResponder, YTAdjustableAccessibilityProtocol>
- (YTMainAppVideoPlayerOverlayView *)videoPlayerOverlayView;
- (id <YTVideoPlayerOverlayDelegate>)delegate;
- (void)didPressVarispeed:(id)arg;
- (void)didPressVideoQuality:(id)arg;
- (BOOL)isFullscreen;
- (CGFloat)totalTime;
@end