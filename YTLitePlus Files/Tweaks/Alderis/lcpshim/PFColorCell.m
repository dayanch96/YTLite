#import "libcolorpicker.h"
#import <Preferences/PSSpecifier.h>

@interface PFColorCell : PFLiteColorCell

@end

@implementation PFColorCell

- (NSString *)_hbcp_defaults {
	return self.specifier.properties[@"color_defaults"];
}

- (NSString *)_hbcp_key {
	return self.specifier.properties[@"color_key"];
}

- (NSString *)_hbcp_default {
	return self.specifier.properties[@"color_fallback"];
}

- (NSString *)_hbcp_postNotification {
	return self.specifier.properties[@"color_postNotification"];
}

- (BOOL)_hbcp_supportsAlpha {
	return self.specifier.properties[@"usesAlpha"] ? ((NSNumber *)self.specifier.properties[@"usesAlpha"]).boolValue : NO;
}

@end
