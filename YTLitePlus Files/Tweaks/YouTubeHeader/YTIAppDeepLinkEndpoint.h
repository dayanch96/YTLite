#import "YTICommand.h"

@interface YTIAppDeepLinkEndpoint : GPBMessage
@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *deepLink;
@property (nonatomic, strong, readwrite) YTICommand *fallbackCommand;
@end
