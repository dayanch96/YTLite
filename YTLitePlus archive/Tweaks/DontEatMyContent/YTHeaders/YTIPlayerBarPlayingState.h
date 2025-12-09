#import "GPBMessage.h"

typedef NS_OPTIONS(int, YTIPlayerBarPlayingStateMode) {
    PLAYER_BAR_MODE_UNKNOWN = 0,
    PLAYER_BAR_MODE_VIDEO = 1,
    PLAYER_BAR_MODE_LIVE = 2,
    PLAYER_BAR_MODE_LIVE_VDR = 3,
    PLAYER_BAR_MODE_AD = 4,
    PLAYER_BAR_MODE_TRAILER = 5,
    PLAYER_BAR_MODE_PRE_INTERSTITIAL_VIDEO = 6,
    PLAYER_BAR_MODE_POST_INTERSTITIAL_VIDEO = 7,
    PLAYER_BAR_MODE_SHORTS = 8,
    PLAYER_BAR_MODE_IMMERSIVE_LIVE = 9,
};

typedef NS_OPTIONS(int, YTIPlayerBarPlayingStateOverlayMode) {
    PLAYER_BAR_OVERLAY_MODE_UNKNOWN = 0,
    PLAYER_BAR_OVERLAY_MODE_DEFAULT = 1,
    PLAYER_BAR_OVERLAY_MODE_QUIET = 2,
};

@interface YTIPlayerBarPlayingState : GPBMessage
@property (nonatomic, assign, readwrite) YTIPlayerBarPlayingStateMode mode;
@property (nonatomic, assign, readwrite) YTIPlayerBarPlayingStateOverlayMode overlayMode;
@property (nonatomic, assign, readwrite) CGFloat totalTimeSec;
@end
