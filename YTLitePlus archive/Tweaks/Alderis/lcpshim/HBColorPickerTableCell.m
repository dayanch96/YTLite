@import Alderis;
#import "libcolorpicker.h"
#import <Preferences/PSSpecifier.h>

@interface UIView ()
- (UIViewController *)_viewControllerForAncestor;
@end

@interface HBColorPickerTableCell () <HBColorPickerDelegate>
@end

@implementation HBColorPickerTableCell {
	HBColorWell *_colorWell;
	HBColorPickerViewController *_viewController;
}

#pragma mark - PSTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	specifier.cellType = PSButtonCell;
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		self.textLabel.textColor = self.tintColor;
		self.textLabel.highlightedTextColor = self.tintColor;

		_colorWell = [[HBColorWell alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
		_colorWell.isDragInteractionEnabled = YES;
		_colorWell.isDropInteractionEnabled = YES;
		[_colorWell addTarget:self action:@selector(_present) forControlEvents:UIControlEventTouchUpInside];
		[_colorWell addTarget:self action:@selector(_colorWellValueChanged:) forControlEvents:UIControlEventValueChanged];
		self.accessoryView = _colorWell;

		// This relies on an implementation detail - do not do this yourself!
		[self addInteraction:[[UIDropInteraction alloc] initWithDelegate:_colorWell]];

		[self _updateValue];
	}
	return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	specifier.cellType = PSButtonCell;
	[super refreshCellContentsWithSpecifier:specifier];
	[self _updateValue];
	self.textLabel.textColor = self.tintColor;
	self.textLabel.highlightedTextColor = self.tintColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	UIColor *color = _colorWell.color;
	[super setHighlighted:highlighted animated:animated];
	// stop deleting my background color Apple!!!
	_colorWell.color = color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (selected) {
		[self _present];
	}
}

- (void)tintColorDidChange {
	[super tintColorDidChange];
	self.textLabel.textColor = self.tintColor;
	self.textLabel.highlightedTextColor = self.tintColor;
}

#pragma mark - Properties

- (NSString *)_hbcp_defaults {
	return self.specifier.properties[@"defaults"];
}

- (NSString *)_hbcp_key {
	return self.specifier.properties[@"key"];
}

- (NSString *)_hbcp_default {
	return self.specifier.properties[@"default"];
}

- (BOOL)_hbcp_supportsAlpha {
	return self.specifier.properties[@"showAlphaSlider"] ? ((NSNumber *)self.specifier.properties[@"showAlphaSlider"]).boolValue : NO;
}

#pragma mark - Getters/setters

- (UIColor *)_colorValue {
	return LCPParseColorString([self.specifier performGetter], self._hbcp_default) ?: [UIColor colorWithWhite:0.6 alpha:1];
}

- (void)_setColorValue:(UIColor *)color {
	[self.specifier performSetterWithValue:color.hbcp_propertyListValue];
	[self _updateValue];
}

- (void)_updateValue {
	_colorWell.color = self._colorValue;
}

#pragma mark - Actions

- (void)_present {
	_viewController = [[HBColorPickerViewController alloc] init];
	_viewController.delegate = self;
	_viewController.popoverPresentationController.sourceView = self;

	HBColorPickerConfiguration *configuration = [[HBColorPickerConfiguration alloc] initWithColor:self._colorValue];
	configuration.title = self.textLabel.text;
	configuration.supportsAlpha = self._hbcp_supportsAlpha;
	_viewController.configuration = configuration;

	UIViewController *rootViewController = self._viewControllerForAncestor ?: self.window.rootViewController;
	[rootViewController presentViewController:_viewController animated:YES completion:nil];
}

- (void)_colorWellValueChanged:(HBColorWell *)sender {
	[self _setColorValue:sender.color];
}

#pragma mark - HBColorPickerDelegate

- (void)colorPicker:(HBColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
	[self _setColorValue:color];
}

@end
