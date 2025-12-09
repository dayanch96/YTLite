#import "YTPlayerViewControllerUIDelegate.h"
#import "YTWatchPlaybackController.h"

@interface YTWatchController : NSObject <YTPlayerViewControllerUIDelegate>
@property (nonatomic, strong, readwrite) YTWatchPlaybackController *watchPlaybackController;
- (void)showFullScreen;
- (void)showSmallScreen;
- (void)reloadStartPlayback:(BOOL)startPlayback;
@end
