#import "YTIToggleButtonRenderer.h"
#import "YTIButtonRenderer.h"

@interface YTIButtonSupportedRenderers : NSObject
@property (nonatomic, strong, readwrite) YTIToggleButtonRenderer *toggleButtonRenderer;
@property (retain, nonatomic) YTIButtonRenderer *buttonRenderer;
@end
