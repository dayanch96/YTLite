#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// YouTube 17.19.2 and higher
@interface YTCommonColorPalette : NSObject
+ (instancetype)lightPalette;
+ (instancetype)darkPalette;
- (NSInteger)pageStyle;
- (UIColor *)background1;
- (UIColor *)background2;
- (UIColor *)background3;
- (UIColor *)staticBlue;
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
- (UIColor *)errorIndicator; // 17.52.1+
- (UIColor *)baseBackground; // 17.52.1+
- (UIColor *)raisedBackground; // 17.52.1+
- (UIColor *)menuBackground; // 17.52.1+
- (UIColor *)invertedBackground; // 17.52.1+
- (UIColor *)additiveBackground; // 17.52.1+
- (UIColor *)outline; // 17.52.1+
@end
