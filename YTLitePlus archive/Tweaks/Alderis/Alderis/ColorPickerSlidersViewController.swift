//
//  ColorPickerSlidersViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit
import AudioToolbox

internal class ColorPickerSlidersViewController: ColorPickerTabViewController {

	static let title = "Sliders"
	static let imageName = "slider.horizontal.3"

	private enum Mode: CaseIterable {
		case rgb, hsl, hsb, white

		var title: String {
			switch self {
			case .rgb:   return "RGB"
			case .hsl:   return "HSL"
			case .hsb:   return "HSB"
			case .white: return "White"
			}
		}

		private var components: [Color.Component] {
			switch self {
			case .rgb:   return [.red, .green, .blue, .alpha]
			case .hsl:   return [.hue, .hslSaturation, .lightness, .alpha]
			case .hsb:   return [.hue, .saturation, .brightness, .alpha]
			case .white: return [.white, .alpha]
			}
		}

		func makeSliders(overrideSmartInvert: Bool, supportsAlpha: Bool) -> [ColorPickerNumericSlider] {
			components.compactMap { component in
				if component.keyPath == \.alpha && !supportsAlpha {
					return nil
				}
				return ColorPickerNumericSlider(component: component, overrideSmartInvert: overrideSmartInvert)
			}
		}
	}

	private var mode: Mode = .rgb {
		didSet { updateMode() }
	}

	private var segmentedControl: UISegmentedControl!

	private var allSliders = [Mode: [ColorPickerNumericSlider]]()
	private var sliderStacks = [Mode: UIStackView]()

	private let colorWell = ColorWell()

	private var hexTextField: UITextField!
	private var hexOptions = Color.HexOptions()

	private var eggLabel: UILabel!
	private var eggString = ""

	override func viewDidLoad() {
		super.viewDidLoad()

		let segmentedControlContainer = UIView()
		segmentedControlContainer.translatesAutoresizingMaskIntoConstraints = false

		segmentedControl = UISegmentedControl(items: Mode.allCases.map(\.title))
		segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
		segmentedControlContainer.addSubview(segmentedControl)

		let topSpacerView = UIView()
		topSpacerView.translatesAutoresizingMaskIntoConstraints = false

		let mainStackView = UIStackView(arrangedSubviews: [segmentedControlContainer, topSpacerView])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		mainStackView.spacing = UIFloat(6)
		view.addSubview(mainStackView)

		for mode in Mode.allCases {
			let modeSliders = mode.makeSliders(overrideSmartInvert: configuration.overrideSmartInvert,
																				 supportsAlpha: configuration.supportsAlpha)
			for slider in modeSliders {
				slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
			}
			allSliders[mode] = modeSliders

			let sliderStackView = UIStackView(arrangedSubviews: modeSliders)
			sliderStackView.axis = .vertical
			sliderStackView.alignment = .fill
			sliderStackView.distribution = .fill
			sliderStackView.spacing = UIFloat(10)
			sliderStacks[mode] = sliderStackView
			mainStackView.addArrangedSubview(sliderStackView)
		}

		colorWell.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		colorWell.isDragInteractionEnabled = true
		colorWell.isDropInteractionEnabled = false

		hexTextField = UITextField()
		hexTextField.translatesAutoresizingMaskIntoConstraints = false
		hexTextField.delegate = self
		hexTextField.textAlignment = .right
		hexTextField.returnKeyType = .done
		hexTextField.autocapitalizationType = .none
		hexTextField.autocorrectionType = .no
		hexTextField.spellCheckingType = .no
		hexTextField.font = Assets.niceMonospaceDigitFont(ofSize: UIFloat(16))
		hexTextField.setContentHuggingPriority(.required, for: .vertical)
		hexTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		eggLabel = UILabel()
		eggLabel.translatesAutoresizingMaskIntoConstraints = false
		eggLabel.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		eggLabel.font = UIFont.systemFont(ofSize: UIFloat(24), weight: .heavy)
		eggLabel.isHidden = true

		let bottomSpacerView = UIView()
		bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.addArrangedSubview(bottomSpacerView)

		let hexStackView = UIStackView(arrangedSubviews: [colorWell, eggLabel, hexTextField])
		hexStackView.translatesAutoresizingMaskIntoConstraints = false
		hexStackView.axis = .horizontal
		hexStackView.alignment = .fill
		hexStackView.distribution = .fill
		hexStackView.spacing = UIFloat(10)
		mainStackView.addArrangedSubview(hexStackView)

		NSLayoutConstraint.activate([
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIFloat(15)),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIFloat(-15)),
			mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIFloat(15)),
			mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: UIFloat(-15)),

			segmentedControl.topAnchor.constraint(equalTo: segmentedControlContainer.topAnchor),
			segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlContainer.bottomAnchor),
			segmentedControl.centerXAnchor.constraint(equalTo: segmentedControlContainer.centerXAnchor),

			topSpacerView.heightAnchor.constraint(equalToConstant: UIFloat(3)),
			bottomSpacerView.heightAnchor.constraint(equalToConstant: UIFloat(3)),

			colorWell.widthAnchor.constraint(equalToConstant: UIFloat(32)),
			colorWell.heightAnchor.constraint(equalTo: colorWell.widthAnchor)
		])

		updateMode()
	}

	@objc func segmentControlChanged(_ sender: UISegmentedControl) {
		view.endEditing(true)
		mode = Mode.allCases[sender.selectedSegmentIndex]
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}

	func updateMode() {
		for (stackMode, stack) in sliderStacks {
			stack.isHidden = stackMode != mode
		}
		colorDidChange()
	}

	func setColor(_ color: Color, hexOptions: Color.HexOptions, shouldBroadcast: Bool = true) {
		self.hexOptions = hexOptions
		super.setColor(color, shouldBroadcast: shouldBroadcast)
	}

	override func setColor(_ color: Color, shouldBroadcast: Bool = true) {
		self.setColor(color, hexOptions: [], shouldBroadcast: shouldBroadcast)
	}

	@objc func sliderChanged(_ slider: ColorPickerNumericSlider) {
		var color = self.color
		slider.apply(to: &color)
		setColor(color)
	}

	override func colorDidChange() {
		allSliders[mode]?.forEach {
			$0.setColor(color)
		}

		colorWell.color = color.uiColor
		hexTextField.text = color.hexString(with: hexOptions)

		if #available(iOS 13, *) {
		} else {
			let foregroundColor: UIColor = color.isDark ? .white : .black
			segmentedControl.setTitleTextAttributes([
				.foregroundColor: foregroundColor
			], for: .selected)
		}
	}

}

extension ColorPickerSlidersViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return true
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = textField.text!.replacingCharacters(in: Range(range, in: textField.text!)!, with: string)
		guard !newString.isEmpty else { return true }

		// #AAAAAA
		eggString = "\(eggString.suffix(3))\(string)"
		if eggString.lowercased() == "holo" {
			self.setColor(Color(red: 51 / 255, green: 181 / 255, blue: 229 / 255, alpha: 1))
			eggLabel.text = "Praise DuARTe"
			eggLabel.textColor = color.uiColor
			eggLabel.isHidden = false
			eggString = ""
			return false
		}

		let canonicalizedString = newString.hasPrefix("#") ? newString.dropFirst() : Substring(newString)
		guard canonicalizedString.count <= 8 else {
			beep()
			return false
		}

		let badCharacterSet = CharacterSet(charactersIn: "0123456789ABCDEFabcdef").inverted
		guard canonicalizedString.rangeOfCharacter(from: badCharacterSet) == nil else {
			beep()
			return false
		}

		if canonicalizedString.count != 6 && canonicalizedString.count != 8 {
			// User is probably still typing it out. Don’t do anything yet.
			return true
		}

		guard var uiColor = UIColor(propertyListValue: "#\(canonicalizedString)") else {
			return true
		}

		if !configuration.supportsAlpha {
			// Discard the alpha component.
			uiColor = uiColor.withAlphaComponent(1)
		}

		let color = Color(uiColor: uiColor)
		OperationQueue.main.addOperation {
			self.setColor(color, hexOptions: canonicalizedString.count == 3 ? .allowShorthand : [])
		}

		return true
	}

}
