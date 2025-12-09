#import "YTPlaybackData.h"
#import "MLVideo.h"

@interface YTSingleVideo : NSObject
- (MLVideo *)video; // Deprecated
- (NSString *)videoId;
- (YTPlaybackData *)playbackData;
@end
