#import "YTIPlaylistPanelRenderer_PlaylistPanelVideoSupportedRenderers.h"

@interface YTIPlaylistPanelRenderer : GPBMessage
@property (nonatomic, copy, readwrite) NSString *playlistId;
@property (nonatomic, strong, readwrite) NSMutableArray <YTIPlaylistPanelRenderer_PlaylistPanelVideoSupportedRenderers *> *contentsArray;
@property (nonatomic, assign, readwrite) int currentIndex;
@property (nonatomic, assign, readwrite) int localCurrentIndex;
@end
