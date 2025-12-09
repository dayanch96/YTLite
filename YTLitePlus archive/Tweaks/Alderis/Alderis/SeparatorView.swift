//
//  SeparatorView.swift
//  Alderis
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class SeparatorView: UIView {

	enum Direction {
		case horizontal, vertical
	}

	var direction: Direction {
		didSet { updateConstraints() }
	}

	private var widthConstraint: NSLayoutConstraint!
	private var heightConstraint: NSLayoutConstraint!

	init(direction: Direction) {
		self.direction = direction
		super.init(frame: .zero)

		backgroundColor = Assets.separatorColor

		widthConstraint = widthAnchor.constraint(equalToConstant: 1)
		heightConstraint = heightAnchor.constraint(equalToConstant: 1)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func updateConstraints() {
		super.updateConstraints()

		let constant = 1 / (window?.screen.scale ?? 1)

		switch direction {
		case .horizontal:
			widthConstraint.isActive = false
			heightConstraint.isActive = true
			heightConstraint.constant = constant
		case .vertical:
			widthConstraint.isActive = true
			heightConstraint.isActive = false
			widthConstraint.constant = constant
		}
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()
		updateConstraints()
	}

}
