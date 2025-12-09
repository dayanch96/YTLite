#import "YTIMediaCommonConfig.h"
#import "YTIHamplayerConfig.h"

@interface MLInnerTubePlayerConfig : NSObject
@property (nonatomic, readonly, strong) YTIMediaCommonConfig *mediaCommonConfig;
@property (nonatomic, readonly, strong) YTIHamplayerConfig *hamplayerConfig;
- (BOOL)varispeedAllowed;
@end