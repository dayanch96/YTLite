#import <Foundation/Foundation.h>

@interface YTCoWatchWatchEndpointWrapperCommandHandler : NSObject
- (void)sendOriginalCommandWithNavigationEndpoint:(id)navigationEndpoint fromView:(id)view entry:(id)entry sender:(id)sender completionBlock:(id)completionBlock;
@end
