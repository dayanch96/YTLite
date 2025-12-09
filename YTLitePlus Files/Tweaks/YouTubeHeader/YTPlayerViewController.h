#import <UIKit/UIKit.h>
#import "GIMMe.h"
#import "YTPlaybackController.h"
#import "YTPlayerOverlayManager.h"
#import "YTPlayerView.h"
#import "YTPlayerViewControllerUIDelegate.h"
#import "YTSingleVideoController.h"
#import "YTVarispeedSwitchController.h"
#import "YTVideoPlayerOverlayDelegate.h"

@interface YTPlayerViewController : UIViewController <YTPlaybackController, YTVideoPlayerOverlayDelegate, YTVarispeedSwitchControllerDelegate>
@property (nonatomic, readonly, assign) BOOL isPlayingAd;
@property (nonatomic, strong, readwrite) NSString *channelID;
@property (nonatomic, strong, readwrite) YTPlayerOverlayManager *overlayManager;
@property (nonatomic, weak, readwrite) id <YTPlayerViewControllerUIDelegate> UIDelegate;
- (GIMMe *)gimme; // Deprecated
- (NSString *)currentVideoID;
- (NSString *)contentVideoID;
- (YTSingleVideoController *)activeVideo;
- (YTVarispeedSwitchController *)varispeedController;
- (CGFloat)currentVideoMediaTime;
- (CGFloat)currentVideoTotalMediaTime;
- (int)playerViewLayout;
- (BOOL)isMDXActive;
- (void)replay;
- (void)replayWithSeekSource:(int)seekSource;
- (void)didPressToggleFullscreen;
- (void)setPlayerViewLayout:(int)layout;
- (void)scrubToTime:(CGFloat)time; // Deprecated
- (void)seekToTime:(CGFloat)time;
- (id)activeVideoPlayerOverlay; // YTMainAppVideoPlayerOverlayViewController || YTInlineMutedPlaybackPlayerOverlayViewController
- (YTPlayerView *)playerView;
- (BOOL)isCurrentVideoVertical;
@end
