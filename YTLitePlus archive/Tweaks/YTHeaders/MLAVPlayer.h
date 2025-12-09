#import "MLAVAssetPlayer.h"
#import "MLAVAssetPlayerDelegate.h"
#import "MLInnerTubePlayerConfig.h"
#import "MLPlayerEventCenter.h"
#import "MLPlayerStickySettings.h"
#import "MLPlayerViewProtocol.h"
#import "MLQueuePlayerDelegate.h"
#import "MLStreamSelectorDelegate.h"
#import "MLVideoFormatConstraint.h"

@interface MLAVPlayer : NSObject <MLAVAssetPlayerDelegate, MLStreamSelectorDelegate>
@property (nonatomic, readwrite, assign) BOOL active;
@property (nonatomic, readonly, assign) BOOL externalPlaybackActive;
@property (nonatomic, readwrite, assign) float rate;
@property (nonatomic, strong, readwrite) NSObject <MLVideoFormatConstraint> *videoFormatConstraint;
@property (nonatomic, readonly, strong) MLVideo *video;
@property (nonatomic, readonly, strong) MLInnerTubePlayerConfig *config;
@property (nonatomic, readonly, strong) MLAVAssetPlayer *assetPlayer;
@property (nonatomic, readonly, strong) MLPlayerEventCenter *playerEventCenter;
@property (nonatomic, readwrite, strong) UIView <MLPlayerViewProtocol> *renderingView;
@property (nonatomic, weak, readwrite) id <MLQueuePlayerDelegate> delegate;
- (instancetype)initWithVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings externalPlaybackActive:(BOOL)externalPlaybackActive;
- (NSArray <MLFormat *> *)selectableVideoFormats;
@end