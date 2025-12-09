#import "GIMMe.h"
#import "YTSingleVideoControllerDelegate.h"

@interface YTLocalPlaybackController : NSObject <YTSingleVideoControllerDelegate>
- (GIMMe *)gimme; // Deprecated
- (NSString *)currentVideoID;
- (int)playerVisibility;
- (void)setMuted:(BOOL)muted;
@end
