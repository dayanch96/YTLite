#import "MLFormat.h"
#import "YTSingleVideoController.h"

@interface YTVideoQualitySwitchRedesignedController : NSObject
- (instancetype)initWithServiceRegistryScope:(id)scope parentResponder:(id)responder;
- (NSArray *)addRestrictedFormats:(NSArray <MLFormat *> *)formats;
- (void)setActiveVideo:(YTSingleVideoController *)video;
@end
