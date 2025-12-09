//
//  BottomSheetTransition.swift
//  Alderis
//
//  Created by Adam Demasi on 20/9/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BottomSheetTransition(direction: true)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BottomSheetTransition(direction: false)
	}

}

internal class BottomSheetTransition: NSObject, UIViewControllerAnimatedTransitioning {

	// Opening: true
	// Closing: false
	let direction: Bool

	init(direction: Bool) {
		self.direction = direction
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		0.4
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		if direction {
			let to = transitionContext.viewController(forKey: .to)!
			transitionContext.containerView.addSubview(to.view)
		}

		Timer.scheduledTimer(withTimeInterval: transitionDuration(using: transitionContext), repeats: false) { _ in
			transitionContext.completeTransition(true)
		}
	}

}
