#import "MLVideo.h"
#import "MLInnerTubePlayerConfig.h"
#import "MLPlayerStickySettings.h"

@interface MLHAMPlayer : NSObject
- (instancetype)initWithVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings playerViewProvider:(id)playerViewProvider;
@end