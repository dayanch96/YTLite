//
//  ColorPickerInnerViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 12/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal extension ColorPickerTab {
	var tabClass: ColorPickerTabViewController.Type {
		switch self {
		case .swatch:		return ColorPickerSwatchViewController.self
		case .map:			return ColorPickerMapViewController.self
		case .sliders:	return ColorPickerSlidersViewController.self
		case .accessibility: return ColorPickerAccessibilityViewController.self
		}
	}

	var index: Int { Self.allCases.firstIndex(of: self)! }
}

internal class ColorPickerInnerViewController: UIViewController {

	weak var delegate: ColorPickerDelegate?
	let configuration: ColorPickerConfiguration
	var color: Color

	var colorPickerTab: ColorPickerTab {
		get { configuration.visibleTabs[currentTab] }
		set { currentTab = configuration.visibleTabs.firstIndex(of: newValue) ?? 0 }
	}

	var compatibilityMode = false

	private var colorPicker: ColorPickerViewController {
		// swiftlint:disable:next force_cast
		parent as! ColorPickerViewController
	}

	init(delegate: ColorPickerDelegate?, configuration: ColorPickerConfiguration) {
		self.delegate = delegate
		self.configuration = configuration
		color = Color(uiColor: configuration.color)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var currentTab = 0 {
		didSet { tabDidChange(oldValue: oldValue) }
	}

	func setColor(_ color: Color, withSource source: ColorPickerTabViewControllerBase? = nil) {
		self.color = color
		colorDidChange(withSource: source)
	}

	private var pageViewController: UIPageViewController!
	private var tabs = [ColorPickerTabViewController]()
	private var tabsView: UISegmentedControl!
	private var titleLabel: UILabel!
	private var cancelButton: DialogButton?
	private var saveButton: DialogButton?
	private var tabsBackgroundView: UIView!
	private var buttonsBackgroundView: UIView?
	private var heightConstraint: NSLayoutConstraint!
	private var backgroundView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()

		for tabType in configuration.visibleTabs {
			let tab = tabType.tabClass.init(tabDelegate: self, configuration: configuration, color: color)
			// Force the view to be initialised
			tab.loadViewIfNeeded()
			tabs.append(tab)
		}

		if configuration.isDropInteractionEnabled {
			view.addInteraction(UIDropInteraction(delegate: self))
		}

		backgroundView = UIView()
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		view.addSubview(backgroundView)

		let tabsCheckerboardView = UIView()
		tabsCheckerboardView.translatesAutoresizingMaskIntoConstraints = false
		tabsCheckerboardView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		tabsCheckerboardView.backgroundColor = Assets.checkerboardPatternColor
		view.addSubview(tabsCheckerboardView)

		tabsBackgroundView = UIView()
		tabsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
		tabsBackgroundView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		view.addSubview(tabsBackgroundView)

		let topSeparatorView = SeparatorView(direction: .horizontal)
		topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		tabsBackgroundView.addSubview(topSeparatorView)

		let titleView = UIView()
		titleView.translatesAutoresizingMaskIntoConstraints = false
		titleView.isHidden = configuration.title == nil || configuration.title!.isEmpty

		titleLabel = UILabel()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textAlignment = .center
		titleLabel.font = .systemFont(ofSize: UIFloat(17), weight: .semibold)
		titleLabel.text = configuration.title
		titleView.addSubview(titleLabel)

		let tabsContainerView = UIView()
		tabsContainerView.translatesAutoresizingMaskIntoConstraints = false
		tabsContainerView.isHidden = !configuration.showTabs

		tabsView = UISegmentedControl()
		tabsView.translatesAutoresizingMaskIntoConstraints = false
		tabsView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		tabsView.addTarget(self, action: #selector(segmentControlChanged(_:)), for: .valueChanged)
		tabsContainerView.addSubview(tabsView)

		if #available(iOS 13, *) {
			tabsView.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.35)
			if isCatalystMac {
				tabsView.setTitleTextAttributes([ .foregroundColor: Assets.macTabBarSelectionColor ], for: .highlighted)
				tabsView.setTitleTextAttributes([ .foregroundColor: Assets.macTabBarSelectionColor ], for: .selected)
			}
		}

		for (i, tab) in tabs.enumerated() {
			let tabClass = type(of: tab)
			#if swift(>=5.3)
			if #available(iOS 14, *) {
				tabsView.insertSegment(action: UIAction(title: tabClass.title,
																								image: tabClass.image,
																								handler: { _ in }),
															 at: i,
															 animated: false)
			} else {
				tabsView.insertSegment(with: tabClass.image, at: i, animated: false)
			}
			#else
			tabsView.insertSegment(with: tabClass.image, at: i, animated: false)
			#endif
		}

		NSLayoutConstraint.activate([
			tabsView.centerXAnchor.constraint(equalTo: tabsContainerView.centerXAnchor),
			tabsView.centerYAnchor.constraint(equalTo: tabsContainerView.centerYAnchor),
			tabsView.leadingAnchor.constraint(greaterThanOrEqualTo: tabsContainerView.leadingAnchor, constant: 4),
			tabsView.trailingAnchor.constraint(lessThanOrEqualTo: tabsContainerView.trailingAnchor, constant: -4)
		])

		if #available(iOS 13, *) {
		} else {
			NSLayoutConstraint.activate([
				tabsView.heightAnchor.constraint(equalToConstant: 32)
			])
			for i in 0..<tabsView.numberOfSegments {
				tabsView.setWidth(40, forSegmentAt: i)
			}
		}

		let pageViewContainer = UIView()
		pageViewContainer.translatesAutoresizingMaskIntoConstraints = false

		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.willMove(toParent: self)
		addChild(pageViewController)
		pageViewContainer.addSubview(pageViewController.view)

		let mainStackView = UIStackView(arrangedSubviews: [titleView, tabsContainerView, pageViewContainer])
		mainStackView.translatesAutoresizingMaskIntoConstraints = false
		mainStackView.axis = .vertical
		mainStackView.alignment = .fill
		mainStackView.distribution = .fill
		view.addSubview(mainStackView)

		heightConstraint = pageViewContainer.heightAnchor.constraint(equalToConstant: 0)

		let barHeight: CGFloat = UIFloat(48)
		let topHeight = (titleView.isHidden ? 0 : barHeight) + (tabsContainerView.isHidden ? 0 : barHeight)
		let titleLabelTopOffset: CGFloat = tabsContainerView.isHidden ? 0 : 3
		NSLayoutConstraint.activate([
			backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
			mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			titleView.heightAnchor.constraint(equalToConstant: barHeight),
			tabsContainerView.heightAnchor.constraint(equalToConstant: barHeight),

			titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: titleLabelTopOffset),
			titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 4),
			titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -4),

			tabsBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			tabsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tabsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tabsBackgroundView.heightAnchor.constraint(equalToConstant: topHeight),

			tabsCheckerboardView.topAnchor.constraint(equalTo: tabsBackgroundView.topAnchor),
			tabsCheckerboardView.bottomAnchor.constraint(equalTo: tabsBackgroundView.bottomAnchor),
			tabsCheckerboardView.leadingAnchor.constraint(equalTo: tabsBackgroundView.leadingAnchor),
			tabsCheckerboardView.trailingAnchor.constraint(equalTo: tabsBackgroundView.trailingAnchor),

			topSeparatorView.leadingAnchor.constraint(equalTo: tabsBackgroundView.leadingAnchor),
			topSeparatorView.trailingAnchor.constraint(equalTo: tabsBackgroundView.trailingAnchor),
			topSeparatorView.bottomAnchor.constraint(equalTo: tabsBackgroundView.bottomAnchor),

			pageViewController.view.topAnchor.constraint(equalTo: pageViewContainer.topAnchor),
			pageViewController.view.bottomAnchor.constraint(equalTo: pageViewContainer.bottomAnchor),
			pageViewController.view.leadingAnchor.constraint(equalTo: pageViewContainer.leadingAnchor),
			pageViewController.view.trailingAnchor.constraint(equalTo: pageViewContainer.trailingAnchor),

			heightConstraint
		])

		if !isCatalystMac {
			let buttonsCheckerboardView = UIView()
			buttonsCheckerboardView.translatesAutoresizingMaskIntoConstraints = false
			buttonsCheckerboardView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
			buttonsCheckerboardView.backgroundColor = Assets.checkerboardPatternColor
			view.insertSubview(buttonsCheckerboardView, aboveSubview: tabsBackgroundView)

			let buttonsBackgroundView = UIView()
			buttonsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
			buttonsBackgroundView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
			view.insertSubview(buttonsBackgroundView, aboveSubview: buttonsCheckerboardView)
			self.buttonsBackgroundView = buttonsBackgroundView

			let bottomSeparatorView = SeparatorView(direction: .horizontal)
			bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
			buttonsBackgroundView.addSubview(bottomSeparatorView)

			let cancelButton = DialogButton()
			cancelButton.translatesAutoresizingMaskIntoConstraints = false
			cancelButton.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
			cancelButton.titleLabel!.font = .systemFont(ofSize: 17, weight: .regular)
			cancelButton.setTitle(Assets.uikitLocalize("Cancel"), for: .normal)
			cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
			self.cancelButton = cancelButton

			let saveButton = DialogButton()
			saveButton.translatesAutoresizingMaskIntoConstraints = false
			saveButton.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
			saveButton.titleLabel!.font = .systemFont(ofSize: 17, weight: .semibold)
			saveButton.setTitle(Assets.uikitLocalize("Done"), for: .normal)
			saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
			self.saveButton = saveButton

			let buttonSeparatorView = SeparatorView(direction: .vertical)
			buttonSeparatorView.translatesAutoresizingMaskIntoConstraints = false
			buttonsBackgroundView.addSubview(buttonSeparatorView)

			let buttonsView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
			buttonsView.translatesAutoresizingMaskIntoConstraints = false
			buttonsView.axis = .horizontal
			buttonsView.alignment = .fill
			mainStackView.addSubview(buttonsView)
			mainStackView.addArrangedSubview(buttonsView)

			NSLayoutConstraint.activate([
				buttonsView.heightAnchor.constraint(equalToConstant: barHeight),

				buttonsBackgroundView.topAnchor.constraint(equalTo: buttonsView.topAnchor),
				buttonsBackgroundView.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
				buttonsBackgroundView.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
				buttonsBackgroundView.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),

				buttonSeparatorView.heightAnchor.constraint(equalToConstant: barHeight / 2),
				buttonSeparatorView.centerXAnchor.constraint(equalTo: buttonsBackgroundView.centerXAnchor),
				buttonSeparatorView.centerYAnchor.constraint(equalTo: buttonsBackgroundView.centerYAnchor),

				buttonsCheckerboardView.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor),
				buttonsCheckerboardView.bottomAnchor.constraint(equalTo: buttonsBackgroundView.bottomAnchor),
				buttonsCheckerboardView.leadingAnchor.constraint(equalTo: buttonsBackgroundView.leadingAnchor),
				buttonsCheckerboardView.trailingAnchor.constraint(equalTo: buttonsBackgroundView.trailingAnchor),

				bottomSeparatorView.leadingAnchor.constraint(equalTo: buttonsBackgroundView.leadingAnchor),
				bottomSeparatorView.trailingAnchor.constraint(equalTo: buttonsBackgroundView.trailingAnchor),
				bottomSeparatorView.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor),

				cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor)
			])
		}

		colorDidChange()
		colorPickerTab = configuration.initialTab
		tabsView?.selectedSegmentIndex = currentTab
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateHeightConstraint()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateHeightConstraint()
	}

	override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
		super.preferredContentSizeDidChange(forChildContentContainer: container)
		updateHeightConstraint()
	}

	private func updateHeightConstraint() {
		heightConstraint.constant = (view.frame.size.width / 12) * 10
		preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}

	@objc private func segmentControlChanged(_ sender: UISegmentedControl) {
		UIView.animate(withDuration: 0.2) {
			self.currentTab = self.tabsView.selectedSegmentIndex
		}
	}

	@objc private func oldTabButtonTapped(_ sender: UIButton) {
		UIView.animate(withDuration: 0.2) {
			self.currentTab = sender.tag
		}
	}

	@objc private func cancelTapped() {
		if !compatibilityMode {
			delegate?.colorPicker?(colorPicker, didSelect: configuration.color)
		}
		delegate?.colorPickerDidCancel?(colorPicker)
		dismiss(animated: true)
	}

	@objc func saveTapped() {
		if compatibilityMode {
			delegate?.colorPicker?(colorPicker, didSelect: color.uiColor)
		} else {
			delegate?.colorPicker?(colorPicker, didAccept: color.uiColor)
		}
		dismiss(animated: true)
	}

	private func colorDidChange(withSource source: ColorPickerTabViewControllerBase? = nil) {
		let uiColor = color.uiColor
		if !compatibilityMode {
			delegate?.colorPicker?(colorPicker, didSelect: uiColor)
		}

		let foregroundColor: UIColor = color.isDark ? .white : .black

		view.tintColor = uiColor
		tabsBackgroundView.backgroundColor = uiColor
		buttonsBackgroundView?.backgroundColor = uiColor
		titleLabel.textColor = foregroundColor
		cancelButton?.setTitleColor(foregroundColor, for: .normal)
		saveButton?.setTitleColor(foregroundColor, for: .normal)
		cancelButton?.highlightBackgroundColor = foregroundColor.withAlphaComponent(0.25)
		saveButton?.highlightBackgroundColor = foregroundColor.withAlphaComponent(0.25)
		tabsView.setTitleTextAttributes([ .foregroundColor: foregroundColor ], for: .normal)

		if #available(iOS 13, *) {
		} else {
			tabsView.tintColor = foregroundColor
		}

		// Even though `shouldBroadcast: false` avoids recursion if we call setColor on the callee tab,
		// doing so on ColorPickerSlidersViewController would reset `hexOptions`, leading to a buggy
		// typing experience in `hexTextField`
		for tab in tabs where tab != source {
			tab.setColor(color, shouldBroadcast: false)
		}

		backgroundView.backgroundColor = uiColor.withAlphaComponent(color.alpha * 0.2)
	}

	private func tabDidChange(oldValue: Int) {
		let stuff = {
			let direction: UIPageViewController.NavigationDirection = self.currentTab < oldValue ? .reverse : .forward
			self.pageViewController.setViewControllers([self.tabs[self.currentTab]], direction: direction, animated: !isCatalystMac)
			self.colorDidChange()

			UIView.animate(withDuration: 0.2) {
				self.view.layoutIfNeeded()
			}
		}
		if isCatalystMac {
			UIView.performWithoutAnimation(stuff)
		} else {
			stuff()
		}
	}

}

extension ColorPickerInnerViewController: ColorPickerTabDelegate {

	func colorPickerTab(_ tab: ColorPickerTabViewControllerBase, didSelect color: Color) {
		setColor(color, withSource: tab)
	}

}

extension ColorPickerInnerViewController: UIDropInteractionDelegate {

	/// :nodoc:
	public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
		return session.items.count == 1 && session.canLoadObjects(ofClass: UIColor.self)
	}

	/// :nodoc:
	public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
		return UIDropProposal(operation: .copy)
	}

	/// :nodoc:
	public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
		session.loadObjects(ofClass: UIColor.self) { items in
			if let color = items.first as? UIColor {
				self.setColor(Color(uiColor: color), withSource: nil)
			}
		}
	}

}

extension ColorPickerInnerViewController: UIPopoverPresentationControllerDelegate {

	/// :nodoc:
	public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
		saveTapped()
	}

}
