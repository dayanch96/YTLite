#import "GPBExtensionDescriptor.h"
#import "YTIEngagementPanelIdentifier.h"

@interface YTIShowEngagementPanelEndpoint : GPBMessage
@property (nonatomic, strong, readwrite) YTIEngagementPanelIdentifier *identifier;
@property (nonatomic, copy, readwrite) NSString *panelIdentifier;
+ (GPBExtensionDescriptor *)showEngagementPanelEndpoint;
@end
