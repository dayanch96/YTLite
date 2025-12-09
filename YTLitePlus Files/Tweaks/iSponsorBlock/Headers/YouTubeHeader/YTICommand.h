#import "YTIReelWatchEndpoint.h"
#import "YTIBrowseEndpoint.h"
#import "YTINavigationEndpointInteractionLoggingExtension.h"

@interface YTICommand : GPBMessage
@property (nonatomic, readwrite, strong) YTIReelWatchEndpoint *reelWatchEndpoint;
@property (nonatomic, readwrite, strong) YTIBrowseEndpoint *browseEndpoint;
@property (nonatomic, readwrite, strong) YTINavigationEndpointInteractionLoggingExtension *interactionLoggingExtension;
@end
