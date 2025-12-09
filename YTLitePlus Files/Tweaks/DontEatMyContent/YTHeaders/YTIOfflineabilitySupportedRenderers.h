#import "YTIButtonRenderer.h"
#import "YTIOfflinePromoRenderer.h"
#import "YTIOfflineabilityRenderer.h"

@interface YTIOfflineabilitySupportedRenderers : NSObject
@property (nonatomic, strong, readwrite) YTIOfflinePromoRenderer *offlinePromoRenderer;
@property (nonatomic, strong, readwrite) YTIOfflineabilityRenderer *offlineabilityRenderer;
@property (nonatomic, strong, readwrite) YTIButtonRenderer *buttonRenderer;
- (int)rendererOneOfCase;
@end