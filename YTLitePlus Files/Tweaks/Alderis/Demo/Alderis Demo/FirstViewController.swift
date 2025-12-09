//
//  FirstViewController.swift
//  Alderis Demo
//
//  Created by Adam Demasi on 15/4/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit
import Alderis

class FirstViewController: UIViewController {

	private var color = UIColor(hue: 0.939614, saturation: 0.811765, brightness: 0.333333, alpha: 1)

	private var colorWell: ColorWell!
	private var uikitWell: UIView?

	// swiftlint:disable:next function_body_length
	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Alderis Demo"
		if #available(iOS 13, *) {
			view.backgroundColor = .systemBackground
		} else {
			view.backgroundColor = .white
		}

		#if targetEnvironment(macCatalyst)
		navigationController?.isNavigationBarHidden = true
		#endif

		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10
		view.addSubview(stackView)

		let mainButton = UIButton(type: .system)
		if #available(iOS 15, *) {
			var config = UIButton.Configuration.filled()
			config.buttonSize = .large
			mainButton.configuration = config
		} else {
			mainButton.titleLabel!.font = UIFont.systemFont(ofSize: 34, weight: .semibold)
		}
		mainButton.setTitle("Present", for: .normal)
		mainButton.addTarget(self, action: #selector(self.presentColorPicker), for: .touchUpInside)
		stackView.addArrangedSubview(mainButton)

		// swiftlint:disable comma
		let buttons: [(title: String, action: Selector)] = [
			("Present with customised title",       #selector(presentColorPickerCustomisedTitle)),
			("Present with customised initial tab", #selector(presentColorPickerCustomisedInitialTab)),
			("Present with customised tabs",        #selector(presentColorPickerCustomisedTabs)),
			("Present with tabs hidden",            #selector(presentColorPickerNoTabs)),
			("Present with customised title, tabs hidden", #selector(presentColorPickerCustomisedTitleNoTabs)),
			("Present without alpha",               #selector(presentColorPickerNoAlpha)),
			("Present without overriding Smart Invert", #selector(presentColorPickerNoOverrideSmartInvert)),
			("Present using deprecated API",        #selector(presentColorPickerDeprecatedAPI)),
			("Present UIKit Color Picker",          #selector(presentUIKitColorPicker))
		]
		// swiftlint:enable comma

		for item in buttons {
			let button = UIButton(type: .system)
			if #available(iOS 15, *) {
				var config = UIButton.Configuration.plain()
				config.buttonSize = .mini
				config.macIdiomStyle = .borderlessTinted
				button.configuration = config
			}
			button.setTitle(item.title, for: .normal)
			button.addTarget(self, action: item.action, for: .touchUpInside)
			stackView.addArrangedSubview(button)
		}

		let spacerView = UIView()
		stackView.addArrangedSubview(spacerView)

		let wellsLabel = UILabel()
		wellsLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		wellsLabel.textAlignment = .center
		wellsLabel.text = "Color wells (try out drag and drop!)"
		stackView.addArrangedSubview(wellsLabel)

		colorWell = ColorWell()
		colorWell.isDragInteractionEnabled = true
		colorWell.isDropInteractionEnabled = true
		colorWell.addTarget(self, action: #selector(self.colorWellValueChanged(_:)), for: .valueChanged)
		colorWell.addTarget(self, action: #selector(self.presentColorPicker), for: .touchUpInside)

		let dragOrDropColorWell = ColorWell()
		dragOrDropColorWell.isDragInteractionEnabled = true
		dragOrDropColorWell.isDropInteractionEnabled = true
		dragOrDropColorWell.color = .systemPurple

		let nonDraggableWell = ColorWell()
		nonDraggableWell.isDragInteractionEnabled = false
		nonDraggableWell.isDropInteractionEnabled = true
		nonDraggableWell.color = .systemOrange

		let nonDroppableWell = ColorWell()
		nonDroppableWell.isDragInteractionEnabled = true
		nonDroppableWell.isDropInteractionEnabled = false
		nonDroppableWell.color = .systemTeal

		let nonDragOrDropWell = ColorWell()
		nonDragOrDropWell.isDragInteractionEnabled = false
		nonDragOrDropWell.isDropInteractionEnabled = false
		nonDragOrDropWell.color = .systemGreen

		let wellsStackView = UIStackView(arrangedSubviews: [colorWell,
																												dragOrDropColorWell,
																												nonDraggableWell,
																												nonDroppableWell,
																												nonDragOrDropWell])
		wellsStackView.translatesAutoresizingMaskIntoConstraints = false
		wellsStackView.axis = .horizontal
		wellsStackView.alignment = .center
		wellsStackView.spacing = 10

		if #available(iOS 14, *) {
			let uikitWell = UIColorWell()
			uikitWell.addTarget(self, action: #selector(self.uikitColorWellValueChanged(_:)), for: .valueChanged)
			wellsStackView.addArrangedSubview(uikitWell)
			self.uikitWell = uikitWell
		}

		stackView.addArrangedSubview(wellsStackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			spacerView.heightAnchor.constraint(equalToConstant: 0)
		])

		var isMac = false
		if #available(iOS 14, *) {
			isMac = UIDevice.current.userInterfaceIdiom == .mac
		}

		NSLayoutConstraint.activate(wellsStackView.arrangedSubviews.flatMap { view in
			[
				view.widthAnchor.constraint(equalToConstant: isMac ? 24 : 32),
				view.heightAnchor.constraint(equalTo: view.widthAnchor)
			]
		})
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		view.window!.tintColor = color
		colorWell.color = color
		if #available(iOS 14, *),
			 let uikitWell = uikitWell as? UIColorWell {
			uikitWell.selectedColor = color
		}
	}

	@objc func colorWellValueChanged(_ sender: ColorWell) {
		NSLog("Color well value changed with value %@", String(describing: sender.color))
		view.window!.tintColor = sender.color
		if #available(iOS 14, *),
			 let uikitWell = uikitWell as? UIColorWell {
			uikitWell.selectedColor = sender.color
		}
	}

	@available(iOS 14, *)
	@objc func uikitColorWellValueChanged(_ sender: UIColorWell) {
		NSLog("UIKit color well value changed with value %@", String(describing: sender.selectedColor))
		view.window!.tintColor = sender.selectedColor
		colorWell.color = sender.selectedColor
	}

	@objc func presentColorPicker(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerCustomisedTitle(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		configuration.title = "Select an Awesome Color"

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerCustomisedInitialTab(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		configuration.initialTab = .map

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerCustomisedTabs(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		configuration.visibleTabs = [.map, .sliders]
		configuration.initialTab = .sliders

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerNoAlpha(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color.withAlphaComponent(0.5))
		configuration.supportsAlpha = false

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerNoTabs(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		configuration.showTabs = false

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerCustomisedTitleNoTabs(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		configuration.title = "Select an Awesome Color"
		configuration.showTabs = false

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerNoOverrideSmartInvert(_ sender: UIView) {
		let configuration = ColorPickerConfiguration(color: color)
		configuration.overrideSmartInvert = false

		let colorPickerViewController = ColorPickerViewController(configuration: configuration)
		colorPickerViewController.delegate = self
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentColorPickerDeprecatedAPI(_ sender: UIView) {
		let colorPickerViewController = ColorPickerViewController()
		colorPickerViewController.delegate = self
		colorPickerViewController.color = color
		colorPickerViewController.popoverPresentationController?.sourceView = sender
		tabBarController!.present(colorPickerViewController, animated: true)
	}

	@objc func presentUIKitColorPicker(_ sender: UIView) {
		if #available(iOS 14, *) {
			let colorPickerViewController = UIColorPickerViewController()
			colorPickerViewController.delegate = self
			colorPickerViewController.selectedColor = color
			colorPickerViewController.popoverPresentationController?.sourceView = sender
			tabBarController!.present(colorPickerViewController, animated: true)
		} else {
			fatalError("UIColorPickerViewController is only available as of iOS 14")
		}
	}

}

extension FirstViewController: ColorPickerDelegate {

	func colorPicker(_ colorPicker: ColorPickerViewController, didSelect color: UIColor) {
		NSLog("User selected color %@ (%@)", color.propertyListValue, String(describing: color))
		self.color = color
		view.window!.tintColor = color
		colorWell.color = color
	}

	func colorPicker(_ colorPicker: ColorPickerViewController, didAccept color: UIColor) {
		NSLog("User accepted color %@ (%@)", color.propertyListValue, String(describing: color))
	}

	func colorPickerDidCancel(_ colorPicker: ColorPickerViewController) {
		NSLog("Color picker cancelled")
	}

}

@available(iOS 14, *)
extension FirstViewController: UIColorPickerViewControllerDelegate {

	func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
		NSLog("UIKit color picker value changed with color %@ (%@)",
					viewController.selectedColor.propertyListValue,
					String(describing: viewController.selectedColor))
		color = viewController.selectedColor
		view.window!.tintColor = viewController.selectedColor
		if let uikitWell = uikitWell as? UIColorWell {
			uikitWell.selectedColor = viewController.selectedColor
		}
	}

	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
		NSLog("UIKit color picker finished")
	}

}
