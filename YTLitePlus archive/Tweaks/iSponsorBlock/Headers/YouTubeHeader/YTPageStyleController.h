#import "YTCommonColorPalette.h"

// Removed in YouTube 20.02.3
@interface YTPageStyleController : NSObject
+ (YTCommonColorPalette *)currentColorPalette; // For YouTube older than 17.19.2, import/change type to YTColorPalette
+ (NSInteger)pageStyle;
@property (nonatomic, assign, readwrite) NSInteger appThemeSetting;
@property (nonatomic, assign, readonly) NSInteger pageStyle;
@end
