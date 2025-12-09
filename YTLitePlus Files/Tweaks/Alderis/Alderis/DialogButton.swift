//
//  DialogButton.swift
//  Alderis
//
//  Created by Adam Demasi on 28/9/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class DialogButton: UIButton {

	var highlightBackgroundColor: UIColor?

	init() {
		super.init(frame: .zero)

		addTarget(self, action: #selector(self.handleTouchDown), for: [.touchDown, .touchDragEnter])
		addTarget(self, action: #selector(self.handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func handleTouchDown() {
		backgroundColor = highlightBackgroundColor
	}

	@objc private func handleTouchUp() {
		backgroundColor = nil
	}

}
