#import "MLVideo.h"
#import "MLInnerTubePlayerConfig.h"

@protocol MLHAMPlayerViewProtocol
- (void)makeActivePlayer;
- (void)setVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig;
@end