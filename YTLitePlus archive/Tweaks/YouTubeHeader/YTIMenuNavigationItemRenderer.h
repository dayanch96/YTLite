#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIIcon.h"

@interface YTIMenuNavigationItemRenderer : GPBMessage
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, assign, readwrite) BOOL hasIcon;
@property (nonatomic, strong, readwrite) YTIFormattedString *text;
@property (nonatomic, assign, readwrite) BOOL hasText;
@property (nonatomic, copy, readwrite) NSString *menuItemIdentifier;
@property (nonatomic, strong, readwrite) YTICommand *navigationEndpoint;
@end
