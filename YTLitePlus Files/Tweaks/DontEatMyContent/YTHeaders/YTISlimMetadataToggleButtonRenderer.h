#import "YTILikeTarget.h"
#import "YTIButtonSupportedRenderers.h"

@interface YTISlimMetadataToggleButtonRenderer : NSObject
@property (nonatomic, strong, readwrite) YTILikeTarget *target;
@property (nonatomic, strong, readwrite) YTIButtonSupportedRenderers *button;
@end
