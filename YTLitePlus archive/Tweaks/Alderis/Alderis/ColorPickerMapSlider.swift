//
//  ColorPickerMapSlider.swift
//  Alderis
//
//  Created by Kabir Oberai on 23/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerMapSlider: ColorPickerComponentSlider {

	init(minImageName: String, maxImageName: String, component: Color.Component, overrideSmartInvert: Bool) {
		super.init(component: component, overrideSmartInvert: overrideSmartInvert)

		stackView.alignment = .center
		stackView.spacing = UIFloat(13)

		let leftImageView = UIImageView(image: Assets.systemImage(named: minImageName))
		leftImageView.translatesAutoresizingMaskIntoConstraints = false
		leftImageView.contentMode = .center
		leftImageView.tintColor = Assets.secondaryLabelColor
		stackView.insertArrangedSubview(leftImageView, at: 0)

		let rightImageView = UIImageView(image: Assets.systemImage(named: maxImageName))
		rightImageView.translatesAutoresizingMaskIntoConstraints = false
		rightImageView.contentMode = .center
		rightImageView.tintColor = Assets.secondaryLabelColor
		stackView.addArrangedSubview(rightImageView)

		if #available(iOS 13, *) {
			let symbolConfig = UIImage.SymbolConfiguration(font: .systemFont(ofSize: UIFloat(18), weight: .medium), scale: .medium)
			leftImageView.preferredSymbolConfiguration = symbolConfig
			rightImageView.preferredSymbolConfiguration = symbolConfig
		}

		NSLayoutConstraint.activate([
			leftImageView.widthAnchor.constraint(equalToConstant: UIFloat(22)),
			leftImageView.widthAnchor.constraint(equalTo: rightImageView.widthAnchor),
			leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor),
			rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
