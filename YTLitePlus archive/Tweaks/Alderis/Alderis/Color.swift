//
//  Color.swift
//  Alderis
//
//  Created by Adam Demasi on 15/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal struct Color: Equatable, Hashable {
	static let black = Color(white: 0, alpha: 1)
	static let white = Color(white: 1, alpha: 1)

	var red: CGFloat = 0 {
		didSet {
			self = Color(red: red, green: green, blue: blue, alpha: alpha)
		}
	}
	var green: CGFloat = 0 {
		didSet {
			self = Color(red: red, green: green, blue: blue, alpha: alpha)
		}
	}
	var blue: CGFloat = 0 {
		didSet {
			self = Color(red: red, green: green, blue: blue, alpha: alpha)
		}
	}

	var hue: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		}
	}
	var saturation: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		}
	}
	var brightness: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		}
	}
	var hslSaturation: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: hslSaturation, lightness: lightness, alpha: alpha)
		}
	}
	var lightness: CGFloat = 0 {
		didSet {
			self = Color(hue: hue, saturation: hslSaturation, lightness: lightness, alpha: alpha)
		}
	}

	var white: CGFloat = 0 {
		didSet {
			self = Color(white: white, alpha: alpha)
		}
	}

	var alpha: CGFloat = 0

	static func == (lhs: Color, rhs: Color) -> Bool {
		lhs.red == rhs.red &&
		lhs.green == rhs.green &&
		lhs.blue == rhs.blue &&
		lhs.alpha == rhs.alpha
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(red)
		hasher.combine(green)
		hasher.combine(blue)
		hasher.combine(alpha)
	}

	var uiColor: UIColor { .init(red: red, green: green, blue: blue, alpha: alpha) }

	init(uiColor: UIColor) {
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
		self.white = brightness
		(self.hslSaturation, self.lightness) = hslValue
	}

	init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
		let uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
		uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
		self.white = brightness
		(self.hslSaturation, self.lightness) = hslValue
	}

	init(white: CGFloat, alpha: CGFloat) {
		self.init(red: white, green: white, blue: white, alpha: alpha)
	}

	init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		self.hue = hue
		self.saturation = saturation
		self.brightness = brightness
		self.white = brightness
		self.alpha = alpha
		let uiColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
		(self.hslSaturation, self.lightness) = hslValue
	}

	init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
		self.hue = hue
		self.hslSaturation = saturation
		self.lightness = lightness
		self.alpha = alpha
		(self.saturation, self.brightness) = hsbValue
		let uiColor = UIColor(hue: hue, saturation: self.saturation, brightness: self.brightness, alpha: alpha)
		uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
		self.white = brightness
	}
}

extension Color {
	static var brightnessThreshold: CGFloat {
		// Accessibility enabled:  conforms to WCAG 2.1 AAA
		// Accessibility disabled: conforms to WCAG 2.1 AA
		UIAccessibility.isDarkerSystemColorsEnabled ? 7 : 4.5
	}

	var relativeLuminanceValues: (red: CGFloat, green: CGFloat, blue: CGFloat) {
		// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
		let values = [red, green, blue]
			.map { $0 <= 0.03928 ? $0 / 12.92 : pow((($0 + 0.055) / 1.055), 2.4) }
		return (values[0], values[1], values[2])
	}

	var relativeLuminance: CGFloat {
		// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
		let (r, g, b) = relativeLuminanceValues
		return (r * 0.2126) + (g * 0.7152) + (b * 0.0722)
	}

	func perceivedBrightness(onBackgroundColor background: Color) -> CGFloat {
		// https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio - between 0-21
		let a = relativeLuminance + 0.05
		let b = background.relativeLuminance + 0.05
		return a > b ? a / b : b / a
	}

	var isDark: Bool { perceivedBrightness(onBackgroundColor: .white) > Self.brightnessThreshold && alpha > 0.5 }
}

extension Color {
	struct HexOptions: OptionSet {
		let rawValue: Int
		static let allowShorthand = Self(rawValue: 1 << 0)
		static let forceAlpha = Self(rawValue: 1 << 1)
	}

	// if the character in `value` is repeated, `repeatedValue` is a single copy of that character. If
	// `value` consists of two unique characters, `repeatedValue` is nil
	// e.g. valid return values are `("AA", "A")` and `("AB", nil)`
	private func hex(_ val: CGFloat) -> (value: String, repeatedValue: Character?) {
		let byte = Int(val * 255) & 0xFF
		let isRepeated = (byte & 0xF) == (byte >> 4)
		let value = String(format: "%02X", byte)
		return (value, isRepeated ? value.first : nil)
	}

	func hexString(with options: HexOptions = []) -> String {
		let (r, rRep) = hex(red)
		let (g, gRep) = hex(green)
		let (b, bRep) = hex(blue)
		let (a, aRep) = hex(alpha)
		let showAlpha = options.contains(.forceAlpha) || alpha != 1
		if options.contains(.allowShorthand),
			let rRep = rRep, let gRep = gRep, let bRep = bRep, let aRep = aRep {
			return "#\(rRep)\(gRep)\(bRep)\(showAlpha ? "\(aRep)" : "")"
		} else {
			return "#\(r)\(g)\(b)\(showAlpha ? a : "")"
		}
	}

	var hexString: String { hexString() }

	var hslValue: (saturation: CGFloat, lightness: CGFloat) {
		let lightness = brightness - (brightness * (saturation / 2))
		var saturation = min(lightness, 1 - lightness)
		saturation = saturation == 0 ? 0 : (brightness - lightness) / saturation
		return (saturation, lightness)
	}

	var hsbValue: (saturation: CGFloat, brightness: CGFloat) {
		let brightness = hslSaturation * min(lightness, 1 - lightness) + lightness
		let saturation = brightness == 0 ? 0 : 2 - 2 * lightness / brightness
		return (saturation, brightness)
	}

	private func cssString(function: String, params: [String?]) -> String {
		let filteredParams = params.compactMap { $0 }
		return "\(function)\(filteredParams.count == 4 ? "a" : "")(\(filteredParams.joined(separator: ", ")))"
	}

	var rgbString: String {
		cssString(function: "rgb", params: [
			"\(Int(red * 255))",
			"\(Int(green * 255))",
			"\(Int(blue * 255))",
			alpha == 1 ? nil : String(format: "%.2f", alpha)
		])
	}

	var hslString: String {
		cssString(function: "hsl", params: [
			"\(Int(hue * 360))",
			"\(Int(hslSaturation * 100))%",
			"\(Int(lightness * 100))%",
			alpha == 1 ? nil : String(format: "%.2f", alpha)
		])
	}

	var objcString: String {
		red == green && green == blue
			? String(format: "[UIColor colorWithWhite:%.3f alpha:%.2f]", white, alpha)
			: String(format: "[UIColor colorWithRed:%.3f green:%.3f blue:%.3f alpha:%.2f]", red, green, blue, alpha)
	}

	var swiftString: String {
		red == green && green == blue
			? String(format: "UIColor(white: %.3f, alpha: %.3f", white, alpha)
			// swiftlint:disable:next color_init
			: String(format: "UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.2f)", red, green, blue, alpha)
	}
}

extension Color {
	struct Component {
		let keyPath: WritableKeyPath<Color, CGFloat>
		let limit: CGFloat
		let title: String
		private let sliderTintColorForColor: (Color) -> [Color]

		init(
			keyPath: WritableKeyPath<Color, CGFloat>,
			limit: CGFloat,
			title: String,
			sliderTintColorForColor: @escaping (Color) -> [Color]
		) {
			self.keyPath = keyPath
			self.limit = limit
			self.title = title
			self.sliderTintColorForColor = sliderTintColorForColor
		}

		init(
			keyPath: WritableKeyPath<Color, CGFloat>,
			limit: CGFloat,
			title: String,
			sliderTint: [Color]
		) {
			self.keyPath = keyPath
			self.limit = limit
			self.title = title
			self.sliderTintColorForColor = { _ in sliderTint }
		}

		func sliderTintColor(for color: Color) -> [Color] {
			sliderTintColorForColor(color)
		}

		static let red: Component = .init(keyPath: \.red, limit: 255, title: "Red") { color in
			[
				Color(red: 0, green: color.green, blue: color.blue, alpha: 1),
				Color(red: 1, green: color.green, blue: color.blue, alpha: 1)
			]
		}

		static let green: Component = .init(keyPath: \.green, limit: 255, title: "Green") { color in
			[
				Color(red: color.red, green: 0, blue: color.blue, alpha: 1),
				Color(red: color.red, green: 1, blue: color.blue, alpha: 1)
			]
		}

		static let blue: Component = .init(keyPath: \.blue, limit: 255, title: "Blue") { color in
			[
				Color(red: color.red, green: color.green, blue: 0, alpha: 1),
				Color(red: color.red, green: color.green, blue: 1, alpha: 1)
			]
		}

		static let hue: Component = .init(keyPath: \.hue, limit: 360, title: "Hue") { color in
			Array(0...8).map { Color(hue: CGFloat($0) * 45 / 360, saturation: color.saturation, brightness: color.brightness, alpha: 1) }
		}

		static let saturation: Component = .init(keyPath: \.saturation, limit: 100, title: "Satur.") { color in
			[
				.white,
				Color(hue: color.hue, saturation: 1, brightness: color.brightness, alpha: 1)
			]
		}

		static let brightness: Component = .init(keyPath: \.brightness, limit: 100, title: "Bright") { color in
			[
				.black,
				Color(hue: color.hue, saturation: color.saturation, brightness: 1, alpha: 1)
			]
		}

		static let hslSaturation: Component = .init(keyPath: \.hslSaturation, limit: 100, title: "Satur.") { color in
			[
				Color(hue: color.hue, saturation: 0, lightness: color.lightness, alpha: 1),
				Color(hue: color.hue, saturation: 1, lightness: color.lightness, alpha: 1)
			]
		}

		static let lightness: Component = .init(keyPath: \.lightness, limit: 100, title: "Light") { color in
			[
				.black,
				Color(hue: color.hue, saturation: color.hslSaturation, lightness: 0.5, alpha: 1),
				.white
			]
		}

		static let white: Component = .init(keyPath: \.white, limit: 255, title: "White") { _ in
			[
				.black,
				.white
			]
		}

		static let alpha: Component = .init(keyPath: \.alpha, limit: 100, title: "Alpha") { color in
			[
				Color(red: color.red, green: color.green, blue: color.blue, alpha: 0),
				Color(red: color.red, green: color.green, blue: color.blue, alpha: 1)
			]
		}
	}
}
