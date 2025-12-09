#import "YTICommand.h"
#import "YTIFormattedString.h"

@interface YTIMenuNavigationItemRenderer : GPBMessage
@property (nonatomic, copy, readwrite) NSString *menuItemIdentifier;
@property (nonatomic, strong, readwrite) YTICommand *navigationEndpoint;
@end
