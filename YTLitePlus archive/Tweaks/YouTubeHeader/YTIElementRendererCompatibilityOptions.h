#import "YTIAdLoggingDataContainer.h"
#import "YTIMenuItemSupportedRenderersElementRendererCompatibilityOptionsExtension.h"

@interface YTIElementRendererCompatibilityOptions : GPBMessage
@property (nonatomic, strong, readwrite) YTIAdLoggingDataContainer *adLoggingData;
@property (nonatomic, assign, readwrite) BOOL hasAdLoggingData;
- (YTIMenuItemSupportedRenderersElementRendererCompatibilityOptionsExtension *)elementsRendererMenuItemExtension;
@end
