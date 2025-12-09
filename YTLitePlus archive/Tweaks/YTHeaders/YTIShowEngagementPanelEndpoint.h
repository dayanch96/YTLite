#import "GPBExtensionDescriptor.h"
#import "YTIEngagementPanelIdentifier.h"

@interface YTIShowEngagementPanelEndpoint : NSObject
@property (nonatomic, strong, readwrite) YTIEngagementPanelIdentifier *identifier;
+ (GPBExtensionDescriptor *)showEngagementPanelEndpoint;
@end
