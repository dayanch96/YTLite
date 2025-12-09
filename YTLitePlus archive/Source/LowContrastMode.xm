#import "../YTLitePlus.h"

// Color Configuration
static UIColor *lcmHexColor = nil;
static UIColor *const kLowContrastColor = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1.0];
static UIColor *const kDefaultTextColor = [UIColor whiteColor];

// Utility Functions
static inline int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}

static inline BOOL lowContrastMode() {
    return IS_ENABLED(@"lowContrastMode_enabled") && contrastMode() == 0;
}

static inline BOOL customContrastMode() {
    return IS_ENABLED(@"lowContrastMode_enabled") && contrastMode() == 1;
}

// static inline UIColor *activeColor() {
//     return customContrastMode() && lcmHexColor ? lcmHexColor : kLowContrastColor;
// }

// Low Contrast Mode v1.7.1.1 (Compatible with only YouTube v19.01.1-v20.21.6)
%group gLowContrastMode
%hook UIColor
+ (UIColor *)colorNamed:(NSString *)name {
    NSArray<NSString *> *targetColors = @[
        @"whiteColor", @"lightTextColor", @"lightGrayColor", @"ychGrey7",
        @"skt_chipBackgroundColor", @"placeholderTextColor", @"systemLightGrayColor",
        @"systemExtraLightGrayColor", @"labelColor", @"secondaryLabelColor",
        @"tertiaryLabelColor", @"quaternaryLabelColor"
    ];
    return [targetColors containsObject:name] ? kLowContrastColor : %orig;
}

+ (UIColor *)whiteColor { return kLowContrastColor; }
+ (UIColor *)lightTextColor { return kLowContrastColor; }
+ (UIColor *)lightGrayColor { return kLowContrastColor; }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)textSecondary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayTextPrimary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayTextSecondary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)iconActive {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)iconActiveOther {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)brandIconActive {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)staticBrandWhite {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayIconActiveOther {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayIconInactive {
    return self.pageStyle == 1 ? [kDefaultTextColor colorWithAlphaComponent:0.7] : %orig;
}
- (UIColor *)overlayIconDisabled {
    return self.pageStyle == 1 ? [kDefaultTextColor colorWithAlphaComponent:0.3] : %orig;
}
- (UIColor *)overlayFilledButtonActive {
    return self.pageStyle == 1 ? [kDefaultTextColor colorWithAlphaComponent:0.2] : %orig;
}
%end

%hook YTColor
+ (BOOL)darkerPaletteTextColorEnabled { return NO; }
+ (UIColor *)white1 { return kLowContrastColor; }
+ (UIColor *)white2 { return kLowContrastColor; }
+ (UIColor *)white3 { return kLowContrastColor; }
+ (UIColor *)white4 { return kLowContrastColor; }
+ (UIColor *)white5 { return kLowContrastColor; }
+ (UIColor *)grey1 { return kLowContrastColor; }
+ (UIColor *)grey2 { return kLowContrastColor; }
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    NSArray<NSString *> *targetLabels = @[@"connect account", @"Thanks", @"Save to playlist", @"Report"];
    for (UIView *subview in self.subviews) {
        if ([targetLabels containsObject:subview.accessibilityLabel]) {
            subview.backgroundColor = kLowContrastColor;
            if ([subview isKindOfClass:[UILabel class]]) {
                ((UILabel *)subview).textColor = [UIColor blackColor];
            }
        }
    }
}
%end

%hook QTMColorGroup
- (UIColor *)tint100 { return kDefaultTextColor; }
- (UIColor *)tint300 { return kDefaultTextColor; }
- (UIColor *)tint500 { return kDefaultTextColor; }
- (UIColor *)tint700 { return kDefaultTextColor; }
- (UIColor *)accent200 { return kDefaultTextColor; }
- (UIColor *)accent400 { return kDefaultTextColor; }
- (UIColor *)accentColor { return kDefaultTextColor; }
- (UIColor *)brightAccentColor { return kDefaultTextColor; }
- (UIColor *)regularColor { return kDefaultTextColor; }
- (UIColor *)darkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColor { return kDefaultTextColor; }
- (UIColor *)lightBodyTextColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnRegularColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnLighterColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnDarkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnAccentColor { return kDefaultTextColor; }
- (UIColor *)buttonBackgroundColor { return kDefaultTextColor; }
- (UIColor *)Color { return kDefaultTextColor; }
%end

%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:kDefaultTextColor];
    %orig(tintedImage);
}
%end

%hook UIExtendedSRGColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:0.9]);
}
%end

%hook UIExtendedSRGBColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:1.0]);
}
%end

%hook UIExtendedGrayColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:1.0]);
}
%end

%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UILabel
+ (void)load {
    [[UILabel appearance] setTextColor:kDefaultTextColor];
}
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    modifiedAttributes[NSForegroundColorAttributeName] = kDefaultTextColor;
    %orig(modifiedAttributes, state);
}
%end

%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    %orig(kDefaultTextColor, state);
}
%end

%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    modifiedAttributes[NSForegroundColorAttributeName] = kDefaultTextColor;
    %orig(modifiedAttributes, state);
}
%end

%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    modifiedAttributes[NSForegroundColorAttributeName] = kDefaultTextColor;
    return %orig(str, modifiedAttributes);
}
%end

%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig(kDefaultTextColor.CGColor);
}
%end

%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *original = %orig;
    NSMutableAttributedString *modified = [original mutableCopy];
    [modified addAttribute:NSForegroundColorAttributeName value:kDefaultTextColor range:NSMakeRange(0, modified.length)];
    return modified;
}
%end

%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UIControl
- (UIColor *)backgroundColor {
    return [UIColor blackColor];
}
%end
%end

// Custom Contrast Mode
%group gCustomContrastMode
%hook UIColor
+ (UIColor *)colorNamed:(NSString *)name {
    NSArray<NSString *> *targetColors = @[
        @"whiteColor", @"lightTextColor", @"lightGrayColor", @"ychGrey7",
        @"skt_chipBackgroundColor", @"placeholderTextColor", @"systemLightGrayColor",
        @"systemExtraLightGrayColor", @"labelColor", @"secondaryLabelColor",
        @"tertiaryLabelColor", @"quaternaryLabelColor"
    ];
    return [targetColors containsObject:name] ? lcmHexColor : %orig;
}

+ (UIColor *)whiteColor { return lcmHexColor; }
+ (UIColor *)lightTextColor { return lcmHexColor; }
+ (UIColor *)lightGrayColor { return lcmHexColor; }
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)textSecondary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayTextPrimary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayTextSecondary {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)iconActive {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)iconActiveOther {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)brandIconActive {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)staticBrandWhite {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayIconActiveOther {
    return self.pageStyle == 1 ? kDefaultTextColor : %orig;
}
- (UIColor *)overlayIconInactive {
    return self.pageStyle == 1 ? [kDefaultTextColor colorWithAlphaComponent:0.7] : %orig;
}
- (UIColor *)overlayIconDisabled {
    return self.pageStyle == 1 ? [kDefaultTextColor colorWithAlphaComponent:0.3] : %orig;
}
- (UIColor *)overlayFilledButtonActive {
    return self.pageStyle == 1 ? [kDefaultTextColor colorWithAlphaComponent:0.2] : %orig;
}
%end

%hook YTColor
+ (BOOL)darkerPaletteTextColorEnabled { return NO; }
+ (UIColor *)white1 { return lcmHexColor; }
+ (UIColor *)white2 { return lcmHexColor; }
+ (UIColor *)white3 { return lcmHexColor; }
+ (UIColor *)white4 { return lcmHexColor; }
+ (UIColor *)white5 { return lcmHexColor; }
+ (UIColor *)grey1 { return lcmHexColor; }
+ (UIColor *)grey2 { return lcmHexColor; }
%end

%hook _ASDisplayView
- (void)layoutSubviews {
    %orig;
    NSArray<NSString *> *targetLabels = @[@"connect account", @"Thanks", @"Save to playlist", @"Report"];
    for (UIView *subview in self.subviews) {
        if ([targetLabels containsObject:subview.accessibilityLabel]) {
            subview.backgroundColor = lcmHexColor;
            if ([subview isKindOfClass:[UILabel class]]) {
                ((UILabel *)subview).textColor = [UIColor blackColor];
            }
        }
    }
}
%end

%hook QTMColorGroup
- (UIColor *)tint100 { return kDefaultTextColor; }
- (UIColor *)tint300 { return kDefaultTextColor; }
- (UIColor *)tint500 { return kDefaultTextColor; }
- (UIColor *)tint700 { return kDefaultTextColor; }
- (UIColor *)accent200 { return kDefaultTextColor; }
- (UIColor *)accent400 { return kDefaultTextColor; }
- (UIColor *)accentColor { return kDefaultTextColor; }
- (UIColor *)brightAccentColor { return kDefaultTextColor; }
- (UIColor *)regularColor { return kDefaultTextColor; }
- (UIColor *)darkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColor { return kDefaultTextColor; }
- (UIColor *)lightBodyTextColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnRegularColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnLighterColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnDarkerColor { return kDefaultTextColor; }
- (UIColor *)bodyTextColorOnAccentColor { return kDefaultTextColor; }
- (UIColor *)buttonBackgroundColor { return kDefaultTextColor; }
- (UIColor *)Color { return kDefaultTextColor; }
%end

%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:kDefaultTextColor];
    %orig(tintedImage);
}
%end

%hook UIExtendedSRGColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:0.9]);
}
%end

%hook UIExtendedSRGBColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:1.0]);
}
%end

%hook UIExtendedGrayColorSpace
- (void)setTextColor:(UIColor *)textColor {
    %orig([kDefaultTextColor colorWithAlphaComponent:1.0]);
}
%end

%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UILabel
+ (void)load {
    [[UILabel appearance] setTextColor:kDefaultTextColor];
}
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    modifiedAttributes[NSForegroundColorAttributeName] = kDefaultTextColor;
    %orig(modifiedAttributes, state);
}
%end

%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    %orig(kDefaultTextColor, state);
}
%end

%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    modifiedAttributes[NSForegroundColorAttributeName] = kDefaultTextColor;
    %orig(modifiedAttributes, state);
}
%end

%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    modifiedAttributes[NSForegroundColorAttributeName] = kDefaultTextColor;
    return %orig(str, modifiedAttributes);
}
%end

%hook CATextLayer
- (void)setTextColor:(CGColorRef)color {
    %orig(kDefaultTextColor.CGColor);
}
%end

%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *original = %orig;
    NSMutableAttributedString *modified = [original mutableCopy];
    [modified addAttribute:NSForegroundColorAttributeName value:kDefaultTextColor range:NSMakeRange(0, modified.length)];
    return modified;
}
%end

%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
    %orig(kDefaultTextColor);
}
%end

%hook UIControl
- (UIColor *)backgroundColor {
    return [UIColor blackColor];
}
%end
%end

// Constructor
%ctor {
    %init;
    if (lowContrastMode()) {
        %init(gLowContrastMode);
    }
    if (customContrastMode()) {
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCustomUIColor"];
        if (colorData) {
            NSError *error = nil;
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:&error];
            if (!error) {
                [unarchiver setRequiresSecureCoding:NO];
                lcmHexColor = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
                if (lcmHexColor) {
                    %init(gCustomContrastMode);
                }
            }
        }
    }
}
