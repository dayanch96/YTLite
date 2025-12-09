#import "YTWatchPlaybackController.h"

@interface YTWatchController : NSObject
@property (nonatomic, strong, readwrite) YTWatchPlaybackController *watchPlaybackController;
- (void)showFullScreen;
- (void)showSmallScreen;
@end
