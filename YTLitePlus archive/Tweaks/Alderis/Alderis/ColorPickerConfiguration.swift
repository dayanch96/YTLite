//
//  ColorPickerConfiguration.swift
//  Alderis
//
//  Created by Adam Demasi on 10/5/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

/// An enumeration of the tabs `ColorPickerViewController` features. Use these enumeration values to
/// set tab-related settings on `ColorPickerConfiguration`.
@objc(HBColorPickerTab)
public enum ColorPickerTab: Int, CaseIterable {
	/// Tab 1: A grid of 9 variations of 11 colours, and a grayscale ramp. The first and default tab.
	case swatch = 0

	/// Tab 2: A color wheel displaying every possible hue and saturation combination. The user can
	/// additionally adjust the brightness of the colour using a slider.
	case map = 1

	/// Tab 3: A set of sliders for red, green, and blue color values, which can be switched to hue,
	/// saturation, and brightness. The user can additionally copy or enter a color value expressed
	/// using a CSS-style hexadecimal string, and adjust alpha transparency.
	case sliders = 2

	/// Tab 4: A tab that allows the user to test various configurations of the color, and its
	/// conformance to WCAG color contrast.
	case accessibility = 3
}

/// ColorPickerConfiguration is used to configure an instance of `ColorPickerViewController`.
@objc(HBColorPickerConfiguration)
open class ColorPickerConfiguration: NSObject {

	/// Initialise a configuration object with the required color property configured.
	@objc public init(color: UIColor) {
		self.color = color
		super.init()
	}

	/// The initial color to use when launching the color picker. Required. If you don’t have a value
	/// set yet, provide a sensible default.
	@objc open var color: UIColor

	/// Whether to allow the user to set an alpha transparency value on the color. This controls the
	/// visibility of an Alpha slider on the Sliders tab. When set to `false`, alpha values provided
	/// via the `color` property, or by the user when entering a hexadecimal value on the Sliders tab,
	/// will be discarded.
	@objc open var supportsAlpha = true

	/// The title to display at the top of the popup. If set to `nil`, no title will be displayed. The
	/// default is `nil`.
	@objc open var title: String?

	/// The initial tab to select when the color picker is presented. The default is
	/// `ColorPickerTab.swatch`.
	///
	/// This value must be found in `visibleTabs`.
	///
	/// - see: `visibleTabs`
	@objc open var initialTab = ColorPickerTab.swatch

	/// The tabs the user can select and switch between at the top of the window, if tabs are enabled
	/// by `showTabs`.
	///
	/// - see: `initialTab`
	@nonobjc open var visibleTabs: [ColorPickerTab] = [.swatch, .map, .sliders, .accessibility]

	/// Maps `visibleTabs` to Objective-C due to Swift limitations. This is an implementation detail.
	/// Ignore this and use `visibleTabs` per usual.
	@objc(visibleTabs)
	open var _visibleTabsObjC: [ColorPickerTab.RawValue] {
		get { visibleTabs.map(\.rawValue) }
		set { visibleTabs = newValue.map { ColorPickerTab(rawValue: $0)! } }
	}

	/// Whether to display the tab selection at the top of the popup. The default is `true`. When set
	/// to `false`, the user will only be able to access the tab specified in initialTab.
	@objc open var showTabs = true

	/// When the Smart Invert accessibility feature is enabled, Alderis instructs the system to not
	/// invert most of its user interface. This ensures the user can make a more accurate color
	/// selection. If this behavior is not desired, you can disable it here.
	@objc open var overrideSmartInvert = true

	/// Whether the user can end a drag interaction by dropping on the color picker window, allowing
	/// them to drag a color from a supporting app. The default is `true`.
	@objc open var isDropInteractionEnabled = true

}
