#import "YTICommand.h"

@interface YTIPivotBarItemRenderer : NSObject
@property (nonatomic, copy, readwrite) NSString *targetId;
- (NSString *)pivotIdentifier;
- (YTICommand *)navigationEndpoint;
- (void)setNavigationEndpoint:(YTICommand *)navigationEndpoint;
@end