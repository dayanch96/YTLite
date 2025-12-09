#import "YTICommand.h"
#import "YTIRenderer.h"
#import "YTRendererForOfflineVideo.h"

@interface YTICompactVideoRenderer : GPBMessage <YTRendererForOfflineVideo>
@property (nonatomic, assign, readwrite) NSString *videoId; // readonly at runtime
@property (nonatomic, assign, readwrite) NSArray <YTIRenderer *> *endSwipeContentsArray; // readonly at runtime
@property (nonatomic, assign, readwrite) YTICommand *navigationEndpoint; // readonly at runtime
@property (nonatomic, strong, readwrite) YTICommand *tappedAction;
@end
