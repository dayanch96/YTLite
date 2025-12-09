#import <UIKit/UIKit.h>
#import "GIMMe.h"
#import "YTPlaybackController.h"
#import "YTPlayerOverlayManager.h"
#import "YTPlayerView.h"
#import "YTSingleVideoController.h"
#import "YTVideoPlayerOverlayDelegate.h"

@interface YTPlayerViewController : UIViewController <YTPlaybackController, YTVideoPlayerOverlayDelegate>
@property (nonatomic, readonly, assign) BOOL isPlayingAd;
@property (nonatomic, strong, readwrite) NSString *channelID;
@property (nonatomic, strong, readwrite) YTPlayerOverlayManager *overlayManager;
- (GIMMe *)gimme; // Deprecated
- (NSString *)currentVideoID;
- (NSString *)contentVideoID;
- (YTSingleVideoController *)activeVideo;
- (CGFloat)currentVideoMediaTime;
- (CGFloat)currentVideoTotalMediaTime;
- (int)playerViewLayout;
- (BOOL)isMDXActive;
- (void)didPressToggleFullscreen;
- (void)setPlayerViewLayout:(int)layout;
- (void)scrubToTime:(CGFloat)time; // Deprecated
- (void)seekToTime:(CGFloat)time;
- (id)activeVideoPlayerOverlay; // YTMainAppVideoPlayerOverlayViewController || YTInlineMutedPlaybackPlayerOverlayViewController
- (YTPlayerView *)playerView;
- (BOOL)isCurrentVideoVertical;
@end
