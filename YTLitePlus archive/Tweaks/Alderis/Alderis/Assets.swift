//
//  Assets.swift
//  Alderis
//
//  Created by Adam Demasi on 27/9/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal struct Assets {

	internal enum SymbolScale: Int {
		case `default` = -1
		case unspecified, small, medium, large

		@available(iOS 13, *)
		var uiImageSymbolScale: UIImage.SymbolScale { UIImage.SymbolScale(rawValue: rawValue)! }
	}

	private static let bundle: Bundle = {
		let myBundle = Bundle(for: ColorPickerViewController.self)
		if let resourcesURL = myBundle.url(forResource: "Alderis", withExtension: "bundle"),
			 let resourcesBundle = Bundle(url: resourcesURL) {
			return resourcesBundle
		}
		return myBundle
	}()
	private static let uikitBundle = Bundle(for: UIView.self)

	// MARK: - Localization

	static func uikitLocalize(_ key: String) -> String {
		uikitBundle.localizedString(forKey: key, value: nil, table: nil)
	}

	// MARK: - Images

	static func systemImage(named name: String, font: UIFont? = nil, scale: SymbolScale = .default) -> UIImage? {
		if #available(iOS 13, *) {
			var configuration: UIImage.SymbolConfiguration?
			if let font = font {
				configuration = UIImage.SymbolConfiguration(font: font, scale: scale.uiImageSymbolScale)
			}
			return UIImage(systemName: name, withConfiguration: configuration)
		}
		return UIImage(named: name, in: bundle, compatibleWith: nil)
	}

	// MARK: - Fonts

	static func niceMonospaceDigitFont(ofSize size: CGFloat) -> UIFont {
		// Take the monospace digit font and enable stylistic alternative 6, which provides a
		// high-legibility, monospace-looking style of the system font.
		let font = UIFont.monospacedDigitSystemFont(ofSize: size, weight: .regular)
		let fontDescriptor = font.fontDescriptor.addingAttributes([
			.featureSettings: [
				[
					.alderisFeature: kStylisticAlternativesType,
					.alderisSelector: kStylisticAltSixOnSelector
				]
			] as [[UIFontDescriptor.FeatureKey: Int]]
		])
		return UIFont(descriptor: fontDescriptor, size: 0)
	}

	// MARK: - Colors

	private static func color(userInterfaceStyles colors: [UIUserInterfaceStyle: UIColor], fallback: UIUserInterfaceStyle = .light) -> UIColor {
		if #available(iOS 13, *) {
			return UIColor { colors[$0.userInterfaceStyle] ?? colors[fallback] ?? colors.values.first! }
		}
		return colors[fallback] ?? colors.values.first!
	}

	static let backdropColor  = UIColor(white: 0, alpha: 0.2)
	static let separatorColor = UIColor(white: 1, alpha: 0.15)

	static let labelColor: UIColor = {
		if #available(iOS 13, *) {
			return .label
		}
		return .black
	}()

	static let secondaryLabelColor: UIColor = {
		if #available(iOS 13, *) {
			return .secondaryLabel
		}
		return UIColor(white: 60 / 255, alpha: 0.6)
	}()

	static let borderColor: UIColor = {
		if #available(iOS 13, *) {
			return .separator
		}
		return UIColor(white: 1, alpha: 0.35)
	}()

	@available(iOS 13, *)
	static let macTabBarSelectionColor = color(userInterfaceStyles: [
		.light: .black,
		.dark: .label
	])

	static let red = UIColor.systemRed

	// .systemGreen adjusted to be more consistent / easier to read
	static let green = color(userInterfaceStyles: [
		.light: UIColor(red: 15 / 255, green: 189 / 255, blue: 59 / 255, alpha: 1),
		// swiftlint:disable:next colon
		.dark:  UIColor(red: 41 / 255, green: 179 / 255, blue: 76 / 255, alpha: 1)
	])

	static let checkerboardPatternColor = color(userInterfaceStyles: [
		.light: renderCheckerboardPattern(colors: (UIColor(white: 200 / 255, alpha: 1),
																							 UIColor(white: 255 / 255, alpha: 1))),
		// swiftlint:disable:next colon
		.dark:  renderCheckerboardPattern(colors: (UIColor(white: 140 / 255, alpha: 1),
																							 UIColor(white: 186 / 255, alpha: 1)))
	])

	private static func renderCheckerboardPattern(colors: (dark: UIColor, light: UIColor)) -> UIColor {
		let size = 11
		let image = UIGraphicsImageRenderer(size: CGSize(width: size * 2, height: size * 2)).image { context in
			colors.dark.setFill()
			context.fill(CGRect(x: 0, y: 0, width: size * 2, height: size * 2))
			colors.light.setFill()
			context.fill(CGRect(x: size, y: 0, width: size, height: size))
			context.fill(CGRect(x: 0, y: size, width: size, height: size))
		}
		return UIColor(patternImage: image)
	}

}
