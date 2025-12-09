#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIIcon.h"

@interface YTIMenuServiceItemRenderer : GPBMessage
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, assign, readwrite) BOOL hasIcon;
@property (nonatomic, strong, readwrite) YTIFormattedString *text;
@property (nonatomic, assign, readwrite) BOOL hasText;
@property (nonatomic, strong, readwrite) YTICommand *serviceEndpoint;
@end
