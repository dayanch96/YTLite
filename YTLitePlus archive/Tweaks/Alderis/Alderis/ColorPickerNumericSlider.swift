//
//  ColorPickerNumericSlider.swift
//  Alderis
//
//  Created by Kabir Oberai on 28/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerNumericSlider: ColorPickerComponentSlider {

	private var textField: UITextField!

	override init(component: Color.Component, overrideSmartInvert: Bool) {
		super.init(component: component, overrideSmartInvert: overrideSmartInvert)

		stackView.alignment = .fill
		stackView.spacing = UIFloat(8)

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: UIFloat(16), weight: .medium)
		label.text = component.title
		stackView.insertArrangedSubview(label, at: 0)

		textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.returnKeyType = .next
		textField.keyboardType = .numberPad
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
		textField.spellCheckingType = .no
		textField.textAlignment = .right
		textField.font = Assets.niceMonospaceDigitFont(ofSize: UIFloat(16))
		stackView.addArrangedSubview(textField)

		NSLayoutConstraint.activate([
			label.widthAnchor.constraint(equalToConstant: UIFloat(50)),
			textField.widthAnchor.constraint(equalToConstant: UIFloat(35))
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setColor(_ color: Color) {
		super.setColor(color)
		textField.text = "\(Int((color[keyPath: component.keyPath] * component.limit).rounded()))"
	}

}

extension ColorPickerNumericSlider: UITextFieldDelegate {

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = textField.text!.replacingCharacters(in: Range(range, in: textField.text!)!, with: string)
		guard !newString.isEmpty else { return true }

		// Numeric only, 0-limit
		let badCharacterSet = CharacterSet(charactersIn: "0123456789").inverted
		guard newString.rangeOfCharacter(from: badCharacterSet) == nil else {
			beep()
			return false
		}
		let limit = component.limit
		guard let value = Int(newString), 0...limit ~= CGFloat(value) else {
			beep()
			return false
		}

		// Run this after the input is fully processed by enqueuing it onto the run loop
		OperationQueue.main.addOperation {
			self.value = CGFloat(value) / limit
			self.sliderChanged()
		}

		return true
	}

}
