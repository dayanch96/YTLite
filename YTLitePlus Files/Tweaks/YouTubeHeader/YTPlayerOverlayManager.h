#import "YTVarispeedSwitchController.h"
#import "YTVideoPlayerOverlayDelegate.h"

@interface YTPlayerOverlayManager : NSObject <YTVideoPlayerOverlayDelegate>
- (YTVarispeedSwitchController *)varispeedController;
- (void)didPressToggleFullscreen;
@end
