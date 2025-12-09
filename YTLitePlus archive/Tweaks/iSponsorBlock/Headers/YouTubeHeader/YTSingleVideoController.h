#import "MLFormat.h"
#import "MLHAMPlayerItem.h"
#import "MLPlayerStickySettings.h"
#import "YTSingleVideoControllerDelegate.h"
#import "YTSingleVideo.h"

@interface YTSingleVideoController : NSObject
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
