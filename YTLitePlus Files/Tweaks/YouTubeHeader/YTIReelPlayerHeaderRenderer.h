#import "YTIAccessibilitySupportedDatas.h"
#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIIcon.h"
#import "YTIThumbnailDetails.h"

@interface YTIReelPlayerHeaderRenderer : GPBMessage
@property (nonatomic, strong, readwrite) YTIFormattedString *channelTitleText;
@property (nonatomic, strong, readwrite) YTIFormattedString *reelTitleText;
@property (nonatomic, strong, readwrite) YTIFormattedString *timestampText;
@property (nonatomic, strong, readwrite) YTIAccessibilitySupportedDatas *accessibility;
@property (nonatomic, strong, readwrite) YTICommand *channelNavigationEndpoint;
@property (nonatomic, strong, readwrite) YTIIcon *channelBadgeIcon;
@property (nonatomic, strong, readwrite) YTIThumbnailDetails *channelThumbnail;
@end
