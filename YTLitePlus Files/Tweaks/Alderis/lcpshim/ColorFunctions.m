@import Alderis;
#import "libcolorpicker.h"

UIColor *LCPParseColorString(NSString *hexString, NSString *fallback) {
	UIColor *result = [[UIColor alloc] initWithHbcp_propertyListValue:hexString];
	if (result == nil && fallback != nil) {
		result = [[UIColor alloc] initWithHbcp_propertyListValue:fallback];
	}
	return result;
}

UIColor *colorFromDefaultsWithKey(NSString *identifier, NSString *key, NSString *fallback) {
	id result = CFBridgingRelease(CFPreferencesCopyValue((__bridge CFStringRef)key, (__bridge CFStringRef)identifier, CFSTR("mobile"), kCFPreferencesCurrentHost));
	if ([result isKindOfClass:NSString.class]) {
		return LCPParseColorString((NSString *)result, fallback);
	}
	return LCPParseColorString(fallback, nil);
}
