//
//  UIFloat.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal let isCatalyst: Bool = {
	if #available(iOS 13, *) {
		return ProcessInfo.processInfo.isMacCatalystApp
	}
	return false
}()

// Catalyst iPad mode, with iOS UI at 0.77 scale
internal let isCatalystPad = isCatalyst && UIDevice.current.userInterfaceIdiom == .pad

// Catalyst Mac mode, with Mac UI at 1.00 scale
internal let isCatalystMac: Bool = {
	#if swift(>=5.3)
	if #available(iOS 14, *) {
		return UIDevice.current.userInterfaceIdiom == .mac
	}
	#endif
	return false
}()

// Inspired by https://www.highcaffeinecontent.com/blog/20220216-Where-Mac-Catalyst-Falls-Short
internal func UIFloat(_ value: CGFloat) -> CGFloat {
	return floor(value * (isCatalystMac ? 0.77 : 1))
}
