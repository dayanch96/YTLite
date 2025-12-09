//
//  UIColorAdditions.swift
//  Alderis
//
//  Created by Ryan Nair on 10/5/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

/// ColorPropertyListValue is a protocol representing types that can be passed to the\
/// `UIColor.init(propertyListValue:)` initialiser. `String` and `Array` both conform to this type.
///
/// - see: `UIColor.init(propertyListValue:)`
public protocol ColorPropertyListValue {}

/// A string can represent a `ColorPropertyListValue`.
///
/// - see: `UIColor.init(propertyListValue:)`
extension String: ColorPropertyListValue {}

/// An array of integers can represent a `ColorPropertyListValue`.
///
/// - see: `UIColor.init(propertyListValue:)`
extension Array: ColorPropertyListValue where Element: FixedWidthInteger {}

/// Alderis provides extensions to `UIColor` for the purpose of serializing and deserializing colors
/// into representations that can be stored in property lists, JSON, and similar formats.
public extension UIColor {

	/// Initializes and returns a color object using data from the specified object.
	///
	/// The value is expected to be one of:
	///
	/// * An array of 3 or 4 integer RGB or RGBA color components, with values between 0 and 255 (e.g.
	///   `[218, 192, 222]`)
	/// * A CSS-style hex string, with an optional alpha component (e.g. `#DAC0DE` or `#DACODE55`)
	/// * A short CSS-style hex string, with an optional alpha component (e.g. `#DC0` or `#DC05`)
	///
	/// Use `-[UIColor initWithHbcp_propertyListValue:]` to access this method from Objective-C.
	///
	/// - parameter value: The object to retrieve data from. See the discussion for the supported object
	/// types.
	/// - returns: An initialized color object, or nil if the value does not conform to the expected
	/// type. The color information represented by this object is in the device RGB colorspace.
	/// - see: `propertyListValue`
	@nonobjc convenience init?(propertyListValue: ColorPropertyListValue?) {
		if let array = propertyListValue as? [Int], array.count == 3 || array.count == 4 {
			let floats = array.map(CGFloat.init(_:))
			self.init(red: floats[0] / 255,
								green: floats[1] / 255,
								blue: floats[2] / 255,
								alpha: array.count == 4 ? floats[3] : 1)
			return
		} else if var string = propertyListValue as? String {
			if string.count == 4 || string.count == 5 {
				let r = String(repeating: string[string.index(string.startIndex, offsetBy: 1)], count: 2)
				let g = String(repeating: string[string.index(string.startIndex, offsetBy: 2)], count: 2)
				let b = String(repeating: string[string.index(string.startIndex, offsetBy: 3)], count: 2)
				let a = string.count == 5 ? String(repeating: string[string.index(string.startIndex, offsetBy: 4)], count: 2) : "FF"
				string = r + g + b + a
			}

			var hex: UInt64 = 0
			let scanner = Scanner(string: string)
			guard scanner.scanString("#", into: nil),
						scanner.scanHexInt64(&hex) else {
				return nil
			}

			if string.count == 9 {
				self.init(red: CGFloat((hex & 0xFF000000) >> 24) / 255,
									green: CGFloat((hex & 0x00FF0000) >> 16) / 255,
									blue: CGFloat((hex & 0x0000FF00) >> 8) / 255,
									alpha: CGFloat((hex & 0x000000FF) >> 0) / 255)
				return
			} else {
				var alpha: Float = 1
				if scanner.scanString(":", into: nil) {
					// Continue scanning to get the alpha component.
					scanner.scanFloat(&alpha)
				}

				self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
									green: CGFloat((hex & 0x00FF00) >> 8) / 255,
									blue: CGFloat((hex & 0x0000FF) >> 0) / 255,
									alpha: CGFloat(alpha))
				return
			}
		}

		return nil
	}

	/// Maps `init(propertyListValue:)` to Objective-C due to Swift limitations. This is an
	/// implementation detail. Ignore this and use `UIColor(propertyListValue:)` or
	/// `-[UIColor initWithHbcp_propertyListValue:]` as per usual.
	///
	/// - parameter value: The object to retrieve data from. See the discussion for the supported
	/// object types.
	/// - returns: An initialized color object, or nil if the value does not conform to the expected
	/// type. The color information represented by this object is in the device RGB colorspace.
	/// device RGB colorspace.
	/// - see: `init(propertyListValue:)`
	@objc(initWithHbcp_propertyListValue:)
	convenience init?(_propertyListValueObjC propertyListValue: Any?) {
		if let value = propertyListValue as? String {
			self.init(propertyListValue: value)
		} else if let value = propertyListValue as? [Int] {
			self.init(propertyListValue: value)
		} else {
			return nil
		}
	}

	/// Returns a string that represents the color.
	///
	/// The output is a string in the format `#AABBCC:0.5`, where the initial `#AABBCC` portion is a
	/// 6-character CSS-style hex string, and the final `:0.5` portion represents the alpha value. If
	/// the color’s alpha value is `1`, the alpha portion is excluded.
	///
	/// If the color is dynamic, for instance if it is a UIKit system color, or initialised via
	/// `UIColor(dynamicProvider:)`, the color that matches the current trait collection is used.
	///
	/// - returns: A string representing the color, in the format discussed above.
	/// - see: `init(propertyListValue:)`
	@objc(hbcp_propertyListValue)
	var propertyListValue: String {
		var alpha: CGFloat = 0
		getRed(nil, green: nil, blue: nil, alpha: &alpha)

		let color = Color(uiColor: self.withAlphaComponent(1))
		let hexString = color.hexString()
		let alphaString = alpha == 1 ? "" : String(format: ":%.5G", alpha)
		return "\(hexString)\(alphaString)"
	}

	/// Returns a hexadecimal string that represents the color.
	///
	/// The output is a string in the format `#AABBCCDD`, where the initial `#AABBCC` portion is a
	/// 6-character CSS-style hex string, and the final `DD` portion is the hexadecimal representation
	/// of the alpha value, supported by [recent web browsers](https://caniuse.com/css-rrggbbaa).
	///
	/// If the color is dynamic, for instance if it is a UIKit system color, or initialised via
	/// `UIColor(dynamicProvider:)`, the color that matches the current trait collection is used.
	///
	/// - returns: A string representing the color, in the format discussed above.
	@objc(hbcp_hexString)
	var hexString: String { Color(uiColor: self).hexString }

	/// Returns an RGB string that represents the color.
	///
	/// The output is a string in the format of `rgba(170, 187, 204, 0.5)`, or `rgb(170, 187, 204)` if
	/// the color’s alpha value is `1`.
	///
	/// If the color is dynamic, for instance if it is a UIKit system color, or initialised via
	/// `UIColor(dynamicProvider:)`, the color that matches the current trait collection is used.
	///
	/// - returns: A string representing the color, in the format discussed above.
	@objc(hbcp_rgbString)
	var rgbString: String { Color(uiColor: self).rgbString }

	/// Returns an HSL string that represents the color.
	///
	/// The output is a string in the format of `hsla(170, 187, 204, 0.5)`, or `hsl(170, 187, 204)` if
	/// the color’s alpha value is `1`.
	///
	/// If the color is dynamic, for instance if it is a UIKit system color, or initialised via
	/// `UIColor(dynamicProvider:)`, the color that matches the current trait collection is used.
	///
	/// - returns: A string representing the color, in the format discussed above.
	@objc(hbcp_hslString)
	var hslString: String { Color(uiColor: self).hslString }

	/// Returns an Objective-C UIColor string that represents the color.
	///
	/// The output is a string in the format of
	/// `[UIColor colorWithRed:0.667 green:0.733 blue:0.800 alpha:1.00]`.
	///
	/// If the color is dynamic, for instance if it is a UIKit system color, or initialised via
	/// `UIColor(dynamicProvider:)`, the color that matches the current trait collection is used.
	///
	/// - returns: A string representing the color, in the format discussed above.
	@objc(hbcp_objcString)
	var objcString: String { Color(uiColor: self).objcString }

	/// Returns a Swift UIColor string that represents the color.
	///
	/// The output is a string in the format of
	/// `UIColor(red: 0.667, green: 0.733, blue: 0.800, alpha: 1.00)`.
	///
	/// If the color is dynamic, for instance if it is a UIKit system color, or initialised via
	/// `UIColor(dynamicProvider:)`, the color that matches the current trait collection is used.
	///
	/// - returns: A string representing the color, in the format discussed above.
	@objc(hbcp_swiftString)
	var swiftString: String { Color(uiColor: self).swiftString }

}
