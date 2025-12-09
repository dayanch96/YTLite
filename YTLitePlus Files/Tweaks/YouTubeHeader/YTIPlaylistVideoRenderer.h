#import "YTIFormattedString.h"
#import "YTIMenuSupportedRenderers.h"
#import "YTRendererForOfflineVideo.h"

@interface YTIPlaylistVideoRenderer : GPBMessage <YTRendererForOfflineVideo>
@property (nonatomic, assign, readwrite) YTICommand *navigationEndpoint; // readonly at runtime
@property (nonatomic, strong, readwrite) YTIFormattedString *index;
@property (nonatomic, strong, readwrite) YTIMenuSupportedRenderers *menu;
@end
