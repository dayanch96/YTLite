#import "YTICommand.h"

@interface YTWatchTransition : NSObject
- (instancetype)initWithNavEndpoint:(YTICommand *)navEndpoint watchEndpointSource:(int)watchEndpointSource forcePlayerReload:(BOOL)forcePlayerReload;
@end;
