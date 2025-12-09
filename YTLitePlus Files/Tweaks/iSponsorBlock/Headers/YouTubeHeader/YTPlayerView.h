#import "MLAVPIPPlayerLayerView.h"
#import "YTPlaybackControllerUIWrapper.h"

@interface YTPlayerView : UIView
@property (retain, nonatomic) MLAVPIPPlayerLayerView *pipRenderingView; // Removed in newer versions
@property (nonatomic, strong, readwrite) UIView *overlayView; // Usually YTMainAppVideoPlayerOverlayView
- (YTPlaybackControllerUIWrapper *)playerViewDelegate;
- (UIView *)renderingView;
@end