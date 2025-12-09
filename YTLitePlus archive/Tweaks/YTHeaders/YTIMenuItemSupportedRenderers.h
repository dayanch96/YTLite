#import "YTIElementRenderer.h"
#import "YTIMenuNavigationItemRenderer.h"

@interface YTIMenuItemSupportedRenderers : GPBMessage
@property (nonatomic, strong, readwrite) YTIElementRenderer *elementRenderer;
@property (nonatomic, strong, readwrite) YTIMenuNavigationItemRenderer *menuNavigationItemRenderer;
@end
