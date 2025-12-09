#import "YTPlaybackData.h"
#import "MLVideo.h"

typedef NS_ENUM(NSInteger, YTSingleVideoType) {
    YTSingleVideoTypeVideo,
    YTSingleVideoTypeAdInterrupt,
    YTSingleVideoTypeContentInterstitial,
    YTSingleVideoTypeTrailer,
};

@interface YTSingleVideo : NSObject
- (MLVideo *)video; // Deprecated
- (NSString *)videoId;
- (YTPlaybackData *)playbackData;
- (YTSingleVideoType)videoType;
@end
