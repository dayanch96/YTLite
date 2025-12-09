#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Deprecated, use YTCommonColorPalette
@interface YTColorPalette : NSObject
+ (instancetype)lightPalette;
+ (instancetype)darkPalette;
+ (instancetype)colorPaletteForPageStyle:(NSInteger)pageStyle;
- (NSInteger)pageStyle;
- (UIColor *)background1;
- (UIColor *)background2;
- (UIColor *)background3;
- (UIColor *)brandBackgroundSolid;
- (UIColor *)brandBackgroundPrimary;
- (UIColor *)brandBackgroundSecondary;
- (UIColor *)generalBackgroundA;
- (UIColor *)generalBackgroundB;
- (UIColor *)generalBackgroundC;
- (UIColor *)errorBackground;
- (UIColor *)textPrimary;
- (UIColor *)textSecondary;
- (UIColor *)textDisabled;
- (UIColor *)textPrimaryInverse;
- (UIColor *)callToAction;
- (UIColor *)iconActive;
- (UIColor *)iconActiveOther;
- (UIColor *)iconInactive;
- (UIColor *)iconDisabled;
- (UIColor *)badgeChipBackground;
- (UIColor *)buttonChipBackgroundHover;
- (UIColor *)touchResponse;
- (UIColor *)callToActionInverse;
- (UIColor *)brandIconActive;
- (UIColor *)brandIconInactive;
- (UIColor *)brandButtonBackground;
- (UIColor *)brandLinkText;
- (UIColor *)tenPercentLayer;
- (UIColor *)snackbarBackground;
- (UIColor *)themedBlue;
- (UIColor *)themedGreen;
- (UIColor *)staticBrandRed;
- (UIColor *)staticBrandWhite;
- (UIColor *)staticBrandBlack;
- (UIColor *)staticClearColor;
- (UIColor *)staticAdYellow;
- (UIColor *)staticGrey;
- (UIColor *)overlayBackgroundSolid;
- (UIColor *)overlayBackgroundHeavy;
- (UIColor *)overlayBackgroundMedium;
- (UIColor *)overlayBackgroundMediumLight;
- (UIColor *)overlayBackgroundLight;
- (UIColor *)overlayTextPrimary;
- (UIColor *)overlayTextSecondary;
- (UIColor *)overlayTextTertiary;
- (UIColor *)overlayIconActiveCallToAction;
- (UIColor *)overlayIconActiveOther;
- (UIColor *)overlayIconInactive;
- (UIColor *)overlayIconDisabled;
- (UIColor *)overlayFilledButtonActive;
- (UIColor *)overlayButtonSecondary;
- (UIColor *)overlayButtonPrimary;
- (UIColor *)overlayBackgroundBrand;
- (UIColor *)overlayBackgroundClear;
- (UIColor *)verifiedBadgeBackground;
- (UIColor *)themedOverlayBackground;
- (UIColor *)adIndicator;
@end
