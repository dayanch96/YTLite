@import Alderis;
#import "libcolorpicker.h"

@implementation UIColor (PFColor)

+ (UIColor *)PF_colorWithHex:(NSString *)hexString {
	return [[self.class alloc] initWithHbcp_propertyListValue:hexString];
}

+ (NSString *)PF_hexFromColor:(UIColor *)color {
	return color.hbcp_propertyListValue;
}

+ (NSString *)hexFromColor:(UIColor *)color {
	NSLog(@"Alderis: +[UIColor(PFColor) hexFromColor:]: Please migrate to +[UIColor(PFColor) PF_hexFromColor:]. This unprefixed method will be removed in future.");
	return [self PF_hexFromColor:color];
}

@end
