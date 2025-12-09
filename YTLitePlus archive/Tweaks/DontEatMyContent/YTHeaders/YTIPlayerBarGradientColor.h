#import "GPBMessage.h"

typedef NS_OPTIONS(int, YTIPlayerBarGradientColorPlayedProgressType) {
    GRADIENT_COLOR_TYPE_UNKNOWN = 0,
    GRADIENT_COLOR_TYPE_ON_PLAYED_PROGRESS = 1,
    GRADIENT_COLOR_TYPE_ON_FULL_PLAYER_BAR = 2,
};

@interface YTIPlayerBarGradientColor : GPBMessage
@property (nonatomic, assign, readwrite) YTIPlayerBarGradientColorPlayedProgressType playedProgressType;
@end
