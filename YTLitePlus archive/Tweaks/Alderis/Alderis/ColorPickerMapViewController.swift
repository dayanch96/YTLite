//
//  ColorPickerMapViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerMapViewController: ColorPickerTabViewController {

	static let title = "Color Wheel"
	static let imageName = "slider.horizontal.below.rectangle"

	private var wheelView: ColorPickerWheelView!
	private var sliders = [ColorPickerMapSlider]()

	override func viewDidLoad() {
		super.viewDidLoad()

		wheelView = ColorPickerWheelView(color: color)
		wheelView.translatesAutoresizingMaskIntoConstraints = false
		wheelView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		wheelView.delegate = self
		view.addSubview(wheelView)

		sliders = [
			ColorPickerMapSlider(
				minImageName: "sun.min", maxImageName: "sun.max", component: .brightness,
				overrideSmartInvert: configuration.overrideSmartInvert
			)
		]

		sliders.forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
		}

		let mainStackView = UIStackView(arrangedSubviews: [wheelView] + sliders)
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		view.addSubview(mainStackView)

		NSLayoutConstraint.activate([
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIFloat(15)),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UIFloat(-15)),
			mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: UIFloat(-10))
		])
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		colorDidChange()
	}

	@objc private func sliderChanged(_ slider: ColorPickerMapSlider) {
		var color = self.color
		slider.apply(to: &color)
		self.setColor(color)
	}

	override func colorDidChange() {
		wheelView.color = color
		sliders.forEach { $0.setColor(color) }
	}

}

extension ColorPickerMapViewController: ColorPickerWheelViewDelegate {

	func colorPickerWheelView(didSelectColor color: Color) {
		self.setColor(color)
	}

}
