#import "YTICommand.h"

@interface YTIPlaylistPanelVideoRenderer : GPBMessage
@property (nonatomic, assign, readonly) NSString *videoId;
@property (nonatomic, assign, readonly) NSString *playlistSetVideoId;
@property (nonatomic, assign, readwrite) YTICommand *navigationEndpoint; // readonly at runtime
@end
