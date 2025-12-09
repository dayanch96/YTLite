//
//  NSBeep.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal typealias NSBeepType = @convention(c) () -> Void

internal let NSBeep: NSBeepType? = {
	if isCatalyst,
		 let appkit = dlopen("/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit", RTLD_LAZY),
		 let beep = dlsym(appkit, "NSBeep") {
		return unsafeBitCast(beep, to: NSBeepType.self)
	}
	return nil
}()

internal func beep() {
	if isCatalyst {
		NSBeep?()
	} else {
		let feedbackGenerator = UINotificationFeedbackGenerator()
		feedbackGenerator.notificationOccurred(.error)
	}
}
