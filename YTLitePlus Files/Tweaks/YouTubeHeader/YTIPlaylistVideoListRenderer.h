#import "YTIPlaylistVideoListSupportedRenderers.h"

@interface YTIPlaylistVideoListRenderer : GPBMessage
@property (nonatomic, copy, readwrite) NSString *playlistId;
@property (nonatomic, strong, readwrite) NSMutableArray <YTIPlaylistVideoListSupportedRenderers *> *contentsArray;
@end
