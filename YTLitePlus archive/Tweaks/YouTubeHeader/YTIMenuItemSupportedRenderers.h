#import "YTIElementRenderer.h"
#import "YTIMenuNavigationItemRenderer.h"
#import "YTIMenuServiceItemRenderer.h"

@interface YTIMenuItemSupportedRenderers : GPBMessage
@property (nonatomic, strong, readwrite) YTIElementRenderer *elementRenderer;
@property (nonatomic, strong, readwrite) YTIMenuNavigationItemRenderer *menuNavigationItemRenderer;
@property (nonatomic, strong, readwrite) YTIMenuServiceItemRenderer *menuServiceItemRenderer;
@end
