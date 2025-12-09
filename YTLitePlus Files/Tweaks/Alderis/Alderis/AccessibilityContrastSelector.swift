//
//  AccessibilityContrastSelector.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class AccessibilityContrastSelector: UIView {

	enum Mode: Int, CaseIterable {
		case color, black, white

		var label: String {
			switch self {
			case .color: return "Color"
			case .black: return "Black"
			case .white: return "White"
			}
		}

		func color(withColor color: Color) -> Color {
			switch self {
			case .color: return color
			case .black: return .black
			case .white: return .white
			}
		}
	}

	var text: String {
		get { label.text! }
		set { label.text = newValue }
	}

	var value: Mode = .white {
		didSet {
			if segmentedControl.selectedSegmentIndex != value.rawValue {
				segmentedControl.selectedSegmentIndex = value.rawValue
				handleChange?(value)
			}
		}
	}

	var handleChange: ((Mode) -> Void)?

	private var label: UILabel!
	private var segmentedControl: UISegmentedControl!

	override init(frame: CGRect) {
		super.init(frame: frame)

		label = UILabel()
		label.font = UIFont.systemFont(ofSize: UIFloat(16), weight: .medium)

		segmentedControl = UISegmentedControl(items: Mode.allCases.map(\.label))
		segmentedControl.addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)

		let stackView = UIStackView(arrangedSubviews: [label, UIView(), segmentedControl])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.spacing = UIFloat(5)
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	convenience init(text: String, value: Mode) {
		self.init(frame: .zero)
		self.text = text
		self.value = value
	}

	@objc private func handleValueChanged() {
		value = Mode(rawValue: segmentedControl.selectedSegmentIndex)!
		handleChange?(value)
	}

}
