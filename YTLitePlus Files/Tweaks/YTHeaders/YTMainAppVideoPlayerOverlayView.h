#import <UIKit/UIKit.h>

#ifdef LEGACY

#import "YTMainAppPlayerOverlayView.h"

@interface YTMainAppVideoPlayerOverlayView : YTMainAppPlayerOverlayView
@end

#else

#import "YTInlinePlayerBarContainerView.h"
#import "YTMainAppControlsOverlayView.h"

@interface YTMainAppVideoPlayerOverlayView : UIView
@property (nonatomic, strong, readwrite) YTInlinePlayerBarContainerView *playerBar;
- (YTMainAppControlsOverlayView *)controlsOverlayView;
@end

#endif