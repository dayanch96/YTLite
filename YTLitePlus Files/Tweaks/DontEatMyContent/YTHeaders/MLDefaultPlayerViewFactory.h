#include "GIMMe.h"
#import "MLVideo.h"
#import "MLInnerTubePlayerConfig.h"
#import "MLAVPlayerLayerView.h"

@interface MLDefaultPlayerViewFactory : NSObject
@property (nonatomic, weak, readwrite) GIMMe *gimme;
- (BOOL)canUsePlayerView:(UIView *)playerView forVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)config;
- (MLAVPlayerLayerView *)AVPlayerViewForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)config;
@end