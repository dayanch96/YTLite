#import "GIMMe.h"
#import "YTResponder.h"
#import "YTSingleVideoControllerDelegate.h"

@interface YTLocalPlaybackController : NSObject <YTSingleVideoControllerDelegate>
- (GIMMe *)gimme; // Deprecated
- (NSString *)currentVideoID;
- (id <YTResponder>)parentResponder;
- (int)playerVisibility;
- (void)setMuted:(BOOL)muted;
- (void)replay;
- (void)replayWithSeekSource:(int)seekSource;
@end
