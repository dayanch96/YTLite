@import Alderis;
#import "libcolorpicker.h"

@interface PFColorAlert () <HBColorPickerDelegate>

@end

@implementation PFColorAlert {
	PFColorAlert *_strongSelf;
	HBColorPickerViewController *_viewController;
	UIColor *_color;
	BOOL _showAlpha;
	PFColorAlertCompletion _completion;
}

+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
	return [[self.class alloc] initWithStartColor:startColor showAlpha:showAlpha];
}

- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
	self = [super init];
	if (self) {
		_color = startColor;
		_showAlpha = showAlpha;
	}
	return self;
}

- (void)displayWithCompletion:(PFColorAlertCompletion)completion {
	_completion = [completion copy];
	_viewController = [[HBColorPickerViewController alloc] init];
	_viewController.delegate = self;

	UIColor *color = _color ?: [UIColor colorWithWhite:0.6 alpha:1];
	HBColorPickerConfiguration *configuration = [[HBColorPickerConfiguration alloc] initWithColor:color];
	configuration.supportsAlpha = _showAlpha;
	_viewController.configuration = configuration;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_15_0
	// Theoretically can do unexpected things if multiple windows are open, but I don’t really care,
	// because this is a bad API design only included for compatibility.
	UIWindow *window = ((UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject).keyWindow;
#else
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
#endif

	_viewController.popoverPresentationController.sourceView = window;
	_viewController.popoverPresentationController.sourceRect = window.bounds;
	_viewController.popoverPresentationController.permittedArrowDirections = 0;
	[window.rootViewController presentViewController:_viewController animated:YES completion:nil];

	// Keep a strong reference to ourself. The color picker delegate is weakly stored by
	// HBColorPickerViewController, but some users of PFColorAlert do not keep a strong reference to
	// the PFColorAlert instance after calling displayWithCompletion:, causing this class to get
	// deallocated and the delegate never called.
	_strongSelf = self;
}

- (void)close {
	_completion(_color);
	_strongSelf = nil;
}

- (void)colorPicker:(HBColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
	_color = [color copy];
	[self close];
}

- (void)colorPickerDidCancel:(HBColorPickerViewController *)colorPicker {
	[self close];
}

@end
