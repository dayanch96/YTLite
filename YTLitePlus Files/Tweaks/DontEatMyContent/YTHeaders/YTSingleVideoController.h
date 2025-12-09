#import "MLFormat.h"
#import "MLHAMPlayerItem.h"
#import "MLPlayerStickySettings.h"
#import "MLQueuePlayerDelegate.h"
#import "YTSingleVideo.h"
#import "YTSingleVideoControllerDelegate.h"

@interface YTSingleVideoController : NSObject <MLQueuePlayerDelegate>
@property (nonatomic, weak, readwrite) NSObject <YTSingleVideoControllerDelegate> *delegate;
@property (nonatomic, strong, readwrite) MLPlayerStickySettings *mediaStickySettings;
@property (nonatomic, strong, readwrite) MLHAMPlayerItem *playerItem;
- (YTSingleVideo *)singleVideo;
- (YTSingleVideo *)videoData;
- (NSArray <MLFormat *> *)selectableVideoFormats;
- (BOOL)isMuted;
- (void)playerRateDidChange:(float)rate;
- (void)setMuted:(BOOL)muted;
@end
