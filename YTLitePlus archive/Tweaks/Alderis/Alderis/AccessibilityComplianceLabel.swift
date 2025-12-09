//
//  AccessibilityComplianceLabel.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class AccessibilityComplianceLabel: UIView {

	var text: String {
		get { label.text! }
		set { label.text = newValue }
	}

	var isCompliant = false {
		didSet { updateState() }
	}

	private let tickImage  = Assets.systemImage(named: "checkmark.circle.fill")
	private let crossImage = Assets.systemImage(named: "xmark.circle.fill")

	private var imageView: UIImageView!
	private var label: UILabel!

	override init(frame: CGRect) {
		super.init(frame: frame)

		let font = UIFont.systemFont(ofSize: UIFloat(16), weight: .medium)

		imageView = UIImageView()
		if #available(iOS 13, *) {
			imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: font, scale: .small)
		}

		label = UILabel()
		label.font = font

		let stackView = UIStackView(arrangedSubviews: [imageView, label])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .center
		stackView.spacing = UIFloat(6)
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	convenience init(text: String) {
		self.init(frame: .zero)
		self.text = text
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func updateState() {
		let color = isCompliant ? Assets.green : Assets.red

		tintColor = color
		accessibilityLabel = "\(text): \(isCompliant ? "Compliant" : "Not compliant")"
		imageView.image = isCompliant ? tickImage : crossImage
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		label.textColor = tintColor
	}

}
