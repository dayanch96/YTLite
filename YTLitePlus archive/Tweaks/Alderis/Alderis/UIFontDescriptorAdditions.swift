//
//  UIFontDescriptorAdditions.swift
//  Alderis
//
//  Created by Adam Demasi on 7/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal extension UIFontDescriptor.FeatureKey {

	// Abstracts a messy API change made in iOS 15.
	static var alderisFeature: Self {
		#if swift(>=5.5)
		if #available(iOS 15, *) {
			return .type
		}
		#endif
		return .featureIdentifier
	}

	static var alderisSelector: Self {
		#if swift(>=5.5)
		if #available(iOS 15, *) {
			return .selector
		}
		#endif
		return .typeIdentifier
	}

}
