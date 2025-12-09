#import "MLVideo.h"
#import "MLInnerTubePlayerConfig.h"

@protocol MLPlayerViewProtocol
- (void)makeActivePlayer;
- (void)setVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig;
@end