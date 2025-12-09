#import "GIMMe.h"
#import "MLVideo.h"
#import "MLInnerTubePlayerConfig.h"

@interface MLPlayerPool : NSObject
@property (nonatomic, weak, readwrite) GIMMe *gimme;
- (void)createHamResourcesForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig;
@end