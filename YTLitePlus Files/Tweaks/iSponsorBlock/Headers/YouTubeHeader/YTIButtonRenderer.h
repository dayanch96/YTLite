#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIIcon.h"

@interface YTIButtonRenderer : NSObject
@property (nonatomic, strong, readwrite) YTICommand *command;
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, strong, readwrite) YTICommand *navigationEndpoint;
@property (nonatomic, copy, readwrite) NSString *targetId;
@property (nonatomic, strong, readwrite) YTIFormattedString *text;
@property (nonatomic, copy, readwrite) NSString *tooltip;
@property (nonatomic, assign, readwrite) int size;
@property (nonatomic, assign, readwrite) int style;
@property (nonatomic, assign, readwrite) BOOL isDisabled;
@end
