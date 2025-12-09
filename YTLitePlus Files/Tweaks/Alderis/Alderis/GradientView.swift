//
//  GradientView.swift
//  Alderis
//
//  Created by Adam Demasi on 11/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class GradientView: UIView {

	override class var layerClass: AnyClass { CAGradientLayer.self }

	// swiftlint:disable:next force_cast
	var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

}
