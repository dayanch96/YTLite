//
//  TextViewLabel.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit
import SafariServices

internal class TextViewLabel: UITextView {

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)

		delegate = self
		backgroundColor = nil
		textContainerInset = .zero
		self.textContainer.lineFragmentPadding = 0
		isEditable = false
		isScrollEnabled = false
		adjustsFontForContentSizeCategory = true
	}

	convenience init() {
		self.init(frame: .zero, textContainer: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		// 🧡 to https://stackoverflow.com/a/44878203/709376 for this
		guard super.point(inside: point, with: event),
					let position = closestPosition(to: point),
					let range = tokenizer.rangeEnclosingPosition(position,
																											 with: .character,
																											 inDirection: .layout(.left)) else {
			return false
		}
		let index = offset(from: beginningOfDocument, to: range.start)
		return attributedText.attribute(.link, at: index, effectiveRange: nil) != nil
	}

	override var selectedRange: NSRange {
		get { NSRange() }
		set {}
	}

	private var viewController: UIViewController? {
		var responder: UIResponder? = self
		while responder != nil {
			if let viewController = responder as? UIViewController {
				return viewController
			}
			responder = responder?.next
		}
		return nil
	}

}

extension TextViewLabel: UITextViewDelegate {

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		#if targetEnvironment(macCatalyst)
		// No need to do anything custom.
		return true
		#else
		switch interaction {
		case .invokeDefaultAction:
			let safariViewController = SFSafariViewController(url: url)
			safariViewController.modalPresentationStyle = .formSheet
			viewController?.present(safariViewController, animated: true)
			return false
		case .presentActions, .preview:
			return true
		@unknown default:
			return true
		}
		#endif
	}

}
