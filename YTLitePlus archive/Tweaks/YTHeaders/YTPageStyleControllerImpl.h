#import "YTCommonColorPalette.h"

// YouTube 20.02.3 and higher
@interface YTPageStyleControllerImpl : NSObject
@property (nonatomic, assign, readwrite) NSInteger appThemeSetting;
@property (nonatomic, assign, readonly) NSInteger pageStyle;
- (YTCommonColorPalette *)currentColorPalette;
@end
