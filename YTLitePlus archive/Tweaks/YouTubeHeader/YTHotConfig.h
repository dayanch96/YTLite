#import "YTIHotConfigGroup.h"
#import "YTIHamplayerHotConfig.h"

@interface YTHotConfig : NSObject
@property (atomic, strong, readwrite) YTIHotConfigGroup *hotConfigGroup;
- (YTIIosMediaHotConfig *)mediaHotConfig;
- (YTIHamplayerHotConfig *)hamplayerHotConfig;
- (BOOL)iosReleasePipControllerOnMain;
@end