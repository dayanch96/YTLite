#import "YTIIosMediaHotConfig.h"
#import "YTIMediaQualitySettingsHotConfig.h"

@interface YTIMediaHotConfig : NSObject
@property (nonatomic, strong, readwrite) YTIIosMediaHotConfig *iosMediaHotConfig;
@property (nonatomic, strong, readwrite) YTIMediaQualitySettingsHotConfig *mediaQualitySettingsHotConfig;
@end