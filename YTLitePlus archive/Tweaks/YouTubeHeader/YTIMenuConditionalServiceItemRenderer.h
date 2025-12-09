#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIIcon.h"

@interface YTIMenuConditionalServiceItemRenderer : GPBMessage
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, assign, readwrite) BOOL hasIcon;
@property (nonatomic, strong, readwrite) YTIIcon *secondaryIcon;
@property (nonatomic, assign, readwrite) BOOL hasSecondaryIcon;
@property (nonatomic, strong, readwrite) YTICommand *serviceEndpoint;
@property (nonatomic, assign, readwrite) BOOL hasServiceEndpoint;
@property (nonatomic, assign, readwrite) int visibilityConditionType;
@property (nonatomic, assign, readwrite) BOOL hasVisibilityConditionType;
@property (nonatomic, strong, readwrite) YTIFormattedString *text;
@property (nonatomic, assign, readwrite) BOOL hasText;
@end
