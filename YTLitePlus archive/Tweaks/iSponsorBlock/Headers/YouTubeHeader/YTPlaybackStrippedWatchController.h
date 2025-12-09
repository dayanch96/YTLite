#import "YTWatchMetadataPanelStateResponderProvider.h"
#import "YTWatchPlaybackController.h"

@interface YTPlaybackStrippedWatchController : NSObject <YTWatchMetadataPanelStateResponderProvider>
@property (nonatomic, strong, readwrite) YTWatchPlaybackController *watchPlaybackController;
@end
