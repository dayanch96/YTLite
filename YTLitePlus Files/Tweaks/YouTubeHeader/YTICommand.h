#import "YTIBrowseEndpoint.h"
#import "YTICommandExecutorCommand.h"
#import "YTINavigationEndpointInteractionLoggingExtension.h"
#import "YTIReelWatchEndpoint.h"
#import "YTIShowEngagementPanelEndpoint.h"
#import "YTIUrlEndpoint.h"
#import "YTIWatchEndpoint.h"

@interface YTICommand : GPBMessage
@property (nonatomic, copy, readwrite) NSData *clickTrackingParams;
@property (nonatomic, readwrite, strong) YTIReelWatchEndpoint *reelWatchEndpoint;
@property (nonatomic, readwrite, strong) YTIWatchEndpoint *watchEndpoint;
@property (nonatomic, readwrite, strong) YTIBrowseEndpoint *browseEndpoint;
@property (nonatomic, readwrite, strong) YTIUrlEndpoint *URLEndpoint;
@property (nonatomic, readwrite, strong) YTINavigationEndpointInteractionLoggingExtension *interactionLoggingExtension;
+ (instancetype)message;
+ (instancetype)browseNavigationEndpointWithBrowseID:(NSString *)browseID;
+ (instancetype)browseNavigationEndpointWithChannelID:(NSString *)channelID;
+ (instancetype)signInNavigationEndpoint;
+ (instancetype)watchNavigationEndpointWithVideoID:(NSString *)videoID;
+ (instancetype)watchNavigationEndpointWithPlaylistID:(NSString *)playlistID videoID:(NSString *)videoID index:(NSUInteger)index watchNextToken:(id)watchNextToken;
+ (instancetype)whatToWatchNavigationEndpoint;
- (YTICommandExecutorCommand *)yt_commandExecutorCommand;
- (YTIShowEngagementPanelEndpoint *)yt_showEngagementPanelEndpoint;
- (BOOL)hasActiveOnlineOrOfflineWatchEndpoint;
@end
