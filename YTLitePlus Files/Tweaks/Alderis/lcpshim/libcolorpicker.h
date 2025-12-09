//
//  Alderis libcolorpicker Compatibility
//  https://github.com/hbang/Alderis
//
//  All interfaces declared in this file are deprecated and only provided for out-of-the-box
//  compatibility with libcolorpicker. Do not write new code that uses these interfaces.
//

@import UIKit;
#import <sys/cdefs.h>
#import <Preferences/PSTableCell.h>

__BEGIN_DECLS
extern UIColor *LCPParseColorString(NSString *hexString, NSString *fallback);

__attribute__((__deprecated__))
extern UIColor *colorFromDefaultsWithKey(NSString *identifier, NSString *key, NSString *fallback);
__END_DECLS

@interface UIColor (PFColor)

+ (UIColor *)PF_colorWithHex:(NSString *)hexString;
+ (NSString *)PF_hexFromColor:(UIColor *)color;

/// Do not use this unprefixed method. Migrate to +[UIColor PF_hexFromColor:] immediately. It will
/// be removed in a future release.
+ (NSString *)hexFromColor:(UIColor *)color __deprecated_msg("Use +[UIColor PF_hexFromColor:]");

@end

typedef void (^PFColorAlertCompletion)(UIColor *color);

@interface PFColorAlert : NSObject

+ (instancetype)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;
- (instancetype)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;

- (void)displayWithCompletion:(PFColorAlertCompletion)completion;
- (void)close;

@end

@interface HBColorPickerTableCell : PSTableCell

@end

@interface PFLiteColorCell : HBColorPickerTableCell

@end

@interface PFSimpleLiteColorCell : PFLiteColorCell

@end
