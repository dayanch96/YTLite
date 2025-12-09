//
//  AppDelegate.swift
//  Alderis Demo
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	// swiftlint:disable:next line_length
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window!.tintColor = UIColor(hue: 0.939614, saturation: 0.811765, brightness: 0.333333, alpha: 1)

		let tabBarController = UITabBarController()
		let viewController = UINavigationController(rootViewController: FirstViewController())
		if #available(iOS 13, *) {
			let tabIcon = UIImage(systemName: "paintbrush.fill")?.withBaselineOffset(fromBottom: 2)
			viewController.tabBarItem = UITabBarItem(title: "Alderis Demo", image: tabIcon, tag: 0)
		}
		tabBarController.viewControllers = [viewController]

		window!.rootViewController = tabBarController
		window!.makeKeyAndVisible()

		return true
	}

}
