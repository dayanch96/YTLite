@import Alderis;
#import "libcolorpicker.h"
#import "HBColorPickerTableCell+Private.h"
#import <Preferences/PSSpecifier.h>

@implementation PFLiteColorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			NSLog(@"Alderis: %@: Using libcolorpicker compatibility class. Please consider switching to HBColorPickerTableCell. This warning will only be logged once.", self.class);
		});
	}
	return self;
}

#pragma mark - Properties

- (NSString *)_hbcp_defaults {
	return self.specifier.properties[@"libcolorpicker"][@"defaults"];
}

- (NSString *)_hbcp_key {
	return self.specifier.properties[@"libcolorpicker"][@"key"];
}

- (NSString *)_hbcp_default {
	return self.specifier.properties[@"libcolorpicker"][@"fallback"];
}

- (NSString *)_hbcp_postNotification {
	return self.specifier.properties[@"libcolorpicker"][@"PostNotification"];
}

- (BOOL)_hbcp_supportsAlpha {
	return self.specifier.properties[@"libcolorpicker"][@"alpha"] ? ((NSNumber *)self.specifier.properties[@"libcolorpicker"][@"alpha"]).boolValue : NO;
}

#pragma mark - Getters/setters

- (UIColor *)_colorValue {
	if (self._hbcp_defaults != nil && self._hbcp_key != nil) {
		// libcolorpicker compatibility
		NSString *path = [NSString stringWithFormat:@THEOS_PACKAGE_INSTALL_PREFIX @"/var/mobile/Library/Preferences/%@.plist", self._hbcp_defaults];
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
		return LCPParseColorString(dictionary[self._hbcp_key], self._hbcp_default);
	}
	return [super _colorValue];
}

- (void)_setColorValue:(UIColor *)color {
	// libcolorpicker compatibility
	if (self._hbcp_defaults != nil && self._hbcp_key != nil) {
		NSLog(@"Alderis: %@: Writing directly to plist file (libcolorpicker compatibility). I’m going to do it since it seems to be somewhat common, but you should be ashamed of yourself. https://hbang.github.io/Alderis/preference-bundles.html", self.class);

		NSString *path = [NSString stringWithFormat:@THEOS_PACKAGE_INSTALL_PREFIX @"/var/mobile/Library/Preferences/%@.plist", self._hbcp_defaults];
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary dictionary];
		dictionary[self._hbcp_key] = color.hbcp_propertyListValue;
		[dictionary writeToFile:path atomically:YES];
		if (self._hbcp_postNotification != nil) {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)self._hbcp_postNotification, nil, nil, YES);
		}
		[self _updateValue];
	} else {
		[super _setColorValue:color];
	}
}

@end
