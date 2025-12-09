//
//  ColorPickerDelegate.swift
//  Alderis
//
//  Created by Adam Demasi on 16/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

/// Use `ColorPickerDelegate` to handle the user’s response to `ColorPickerViewController`.
@objc(HBColorPickerDelegate)
public protocol ColorPickerDelegate: NSObjectProtocol {

	/// Informs the delegate that the user has selected a color in the color picker. Optional.
	///
	/// Use this to update your user interface with the new color value, if suitable to your use case.
	///
	/// You should, at minimum, implement either this method or `colorPicker(_:didAccept:)`. If you
	/// don’t intend to implement this method, it is expected that you implement
	/// `colorPicker(_:didAccept:)`. If you implement this method and the user selects Cancel, this
	/// method will be called with the initial color passed in via `ColorPickerConfiguration.color` to
	/// undo the selection.
	///
	/// - parameter colorPicker: The `ColorPickerViewController` instance that triggered the action.
	/// - parameter color: The `UIColor` selection the user made.
	/// - see: `colorPicker(_:didAccept:)`
	@objc(colorPicker:didSelectColor:)
	optional func colorPicker(_ colorPicker: ColorPickerViewController, didSelect color: UIColor)

	/// Informs the delegate that the user has dismissed the color picker with a positive response,
	/// having selected the selected color. Optional.
	///
	/// You should, at minimum, implement either this method or `colorPicker(_:didSelect:)`.
	///
	/// - parameter colorPicker: The `ColorPickerViewController` instance that triggered the action.
	/// - parameter color: The `UIColor` selection the user made.
	/// - see: `colorPicker(_:didSelect:)`
	@objc(colorPicker:didAcceptColor:)
	optional func colorPicker(_ colorPicker: ColorPickerViewController, didAccept color: UIColor)

	/// Informs the delegate that the user has dismissed the color picker with a negative response.
	/// Optional.
	///
	/// You usually do not need to handle this condition.
	///
	/// - parameter colorPicker: The `ColorPickerViewController` instance that triggered the action.
	@objc(colorPickerDidCancel:)
	optional func colorPickerDidCancel(_ colorPicker: ColorPickerViewController)

}
