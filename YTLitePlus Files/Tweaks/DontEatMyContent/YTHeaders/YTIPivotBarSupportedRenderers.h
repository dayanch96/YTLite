#import "YTIPivotBarItemRenderer.h"
#import "YTIPivotBarIconOnlyItemRenderer.h"

@interface YTIPivotBarSupportedRenderers : NSObject
- (YTIPivotBarItemRenderer *)pivotBarItemRenderer;
- (YTIPivotBarIconOnlyItemRenderer *)pivotBarIconOnlyItemRenderer;
@end