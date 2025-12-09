#import "YTICommand.h"
#import "YTIFormattedString.h"
#import "YTIIcon.h"

typedef enum : int {
    SIZE_DEFAULT = 1,
} YTIButtonRenderer_Size;

typedef enum : int {
    STYLE_UNKNOWN = 0,
    STYLE_DEFAULT = 1,
    STYLE_PRIMARY = 2,
    STYLE_DESTRUCTIVE = 3,
    STYLE_DARK = 4,
    STYLE_LIGHT = 5,
    STYLE_PAYMENT = 6,
    STYLE_TEXT = 7,
    STYLE_OPACITY = 8,
    STYLE_ALERT_ERROR = 9,
    STYLE_ALERT_INFO = 10,
    STYLE_ALERT_SUCCESS = 11,
    STYLE_ALERT_WARN = 12,
    STYLE_BLUE_TEXT = 13,
    STYLE_BRAND = 14,
    STYLE_LIGHT_TEXT = 15,
    STYLE_RED_TEXT = 16,
    STYLE_BLACK = 17,
    STYLE_WHITE_WITH_BORDER = 18,
    STYLE_COMPACT_GRAY = 19,
    STYLE_SUGGESTIVE = 20,
    STYLE_WHITE_TRANSLUCENT = 21,
    STYLE_DARK_ON_BLACK = 22,
    STYLE_BLUE_TEXT_WITH_INVERSE_THEME = 23,
    STYLE_VISIBLY_DISABLED = 24,
    STYLE_INACTIVE_OUTLINE = 25,
    STYLE_DARK_ON_WHITE = 26,
    STYLE_THEMED_TEXT = 28,
    STYLE_COUNT = 29,
    STYLE_OVERLAY = 30,
    STYLE_OUTLINE = 31,
    STYLE_CALL_TO_ACTION_FILLED = 33,
    STYLE_BLACK_OUTLINE = 34,
    STYLE_BLACK_FILLED = 35,
    STYLE_CTA_LOW_EMPHASIS_OUTLINE = 36,
    STYLE_ORANGE = 37,
    STYLE_WHITE_TRANSLUCENT_NO_OUTLINE = 38,
    STYLE_MONO_TONAL = 39,
    STYLE_MONO_TONAL_OVERLAY = 40,
    STYLE_MONO_FILLED_OVERLAY = 41,
    STYLE_MONO_FILLED = 42,
    STYLE_MONO_OUTLINE = 43,
    STYLE_MONO_TEXT = 44,
} YTIButtonRenderer_Style;

@interface YTIButtonRenderer : NSObject
@property (nonatomic, strong, readwrite) YTICommand *command;
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, strong, readwrite) YTICommand *navigationEndpoint;
@property (nonatomic, strong, readwrite) YTICommand *serviceEndpoint;
@property (nonatomic, copy, readwrite) NSString *targetId;
@property (nonatomic, strong, readwrite) YTIFormattedString *text;
@property (nonatomic, copy, readwrite) NSString *tooltip;
@property (nonatomic, assign, readwrite) YTIButtonRenderer_Size size;
@property (nonatomic, assign, readwrite) YTIButtonRenderer_Style style;
@property (nonatomic, assign, readwrite) BOOL isDisabled;
@end
