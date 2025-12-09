#import "YTIPlayerBarDecorationStyle.h"
#import "YTIPlayerBarPlayingState.h"

@interface YTIPlayerBarDecorationModel : GPBMessage
@property (nonatomic, strong, readwrite) YTIPlayerBarDecorationStyle *style;
@property (nonatomic, strong, readwrite) YTIPlayerBarPlayingState *playingState;
@end
