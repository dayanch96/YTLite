#import "YTAdjustableAccessibilityProtocol.h"
#import "YTMainAppVideoPlayerOverlayView.h"
#import "YTPlayerBarController.h"
#import "YTResponder.h"
#import "YTVideoPlayerOverlayDelegate.h"

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController <YTResponder, YTAdjustableAccessibilityProtocol>
@property (nonatomic, strong, readwrite) YTPlayerBarController *playerBarController;
@property (nonatomic, weak, readwrite) id <YTVideoPlayerOverlayDelegate> delegate;
- (YTMainAppVideoPlayerOverlayView *)videoPlayerOverlayView;
- (void)didPressAudioTrackSwitch:(id)sender;
- (void)didPressVarispeed:(id)sender;
- (void)didPressVideoQuality:(id)sender;
- (void)didPressOverflow:(id)sender;
- (void)setPlaybackRate:(CGFloat)rate;
- (BOOL)isFullscreen;
- (CGFloat)totalTime;
- (CGFloat)currentPlaybackRate;
@end