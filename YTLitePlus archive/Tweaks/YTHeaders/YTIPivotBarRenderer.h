#import "YTIPivotBarSupportedRenderers.h"

@interface YTIPivotBarRenderer : NSObject
+ (YTIPivotBarSupportedRenderers *)pivotSupportedRenderersWithBrowseId:(NSString *)browseId title:(NSString *)title iconType:(int)iconType;
- (NSMutableArray <YTIPivotBarSupportedRenderers *> *)itemsArray;
@end