//
//  ColorWell.swift
//  Alderis
//
//  Created by Adam Demasi on 15/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit
import CoreServices

/// ColorWell can be used to present the user’s color selection in your user interface. It
/// optionally also supports drag-and-drop operations.
///
/// By default, drop interactions are supported, which causes a `UIControl.Event.valueChanged` event
/// to be emitted. Optionally, drag operations can be enabled, allowing the color to be dropped
/// elsewhere.
///
/// You can also use `UIControl.Event.touchUpInside` to perform an action, such as to initialise
/// and present an instance of `ColorPickerViewController`.
@objc(HBColorWell)
open class ColorWell: UIControl {

	/// Set the color to be displayed by the view.
	@objc open var color: UIColor? {
		get { colorView.backgroundColor }
		set { colorView.backgroundColor = newValue }
	}

	/// Override the default border color if desired.
	@objc open var borderColor: UIColor? {
		didSet { updateBorderColor() }
	}

	/// Whether the user can begin a drag interaction from this view, allowing them to drop the color
	/// into a supporting app. The default is `false`.
	@objc open var isDragInteractionEnabled = false {
		didSet { updateDragDropInteraction() }
	}

	/// Whether the user can end a drag interaction by dropping on this view, allowing them to drag a
	/// color from a supporting app onto this view. The default is true.
	///
	/// To handle a color being dropped on this view, add an action for the `.valueChanged` event. For
	/// example:
	///
	/// ```swift
	/// colorWell.addTarget(self, action: #selector(self.handleColorDidChange(_:)), for: .valueChanged)
	/// ```
	@objc open var isDropInteractionEnabled = true {
		didSet { updateDragDropInteraction() }
	}

	#if swift(>=5.3)
	/// Whether the user can long press (iPhone) or right-click (Mac/iPad) the view, allowing them to
	/// copy the color in various formats, or paste a color from another source.
	///
	/// To handle a color being pasted via the context menu, add an action for the `.valueChanged`
	/// event. For example:
	///
	/// ```swift
	/// colorWell.addTarget(self, action: #selector(self.handleColorDidChange(_:)), for: .valueChanged)
	/// ```
	///
	/// Requires iOS 14 or newer.
	@available(iOS 14, *)
	open override var isContextMenuInteractionEnabled: Bool {
		didSet { updateDragDropInteraction() }
	}
	#endif

	private var colorView: UIView!
	private var dragInteraction: UIDragInteraction!
	private var dropInteraction: UIDropInteraction!
	private var tapGestureRecognizer: UITapGestureRecognizer!

	private var contextMenuTitle: String {
		if let color = color {
			return "Color: \(Color(uiColor: color).hexString())"
		}
		return "No color"
	}

	/// :nodoc:
	override init(frame: CGRect) {
		super.init(frame: frame)
		setUp()
	}

	/// :nodoc:
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setUp()
	}

	private func setUp() {
		clipsToBounds = true
		backgroundColor = Assets.checkerboardPatternColor
		borderColor = .white
		layer.masksToBounds = false
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = .zero
		layer.shadowOpacity = 0.75
		layer.shadowRadius = 1

		colorView = UIView()
		colorView.translatesAutoresizingMaskIntoConstraints = false
		colorView.clipsToBounds = true
		addSubview(colorView)

		dragInteraction = UIDragInteraction(delegate: self)
		dragInteraction.isEnabled = true
		dropInteraction = UIDropInteraction(delegate: self)
		updateDragDropInteraction()

		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGestureRecognizerFired(_:)))
		tapGestureRecognizer.isEnabled = false
		addGestureRecognizer(tapGestureRecognizer)

		#if swift(>=5.3)
		if #available(iOS 14, *) {
			isContextMenuInteractionEnabled = true
		}
		#endif

		#if swift(>=5.5)
		if #available(iOS 15, *) {
			toolTip = contextMenuTitle
			toolTipInteraction?.delegate = self
		}
		#endif

		NSLayoutConstraint.activate([
			self.widthAnchor.constraint(greaterThanOrEqualToConstant: UIFloat(32)),
			self.heightAnchor.constraint(equalTo: self.widthAnchor),

			colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			colorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			colorView.topAnchor.constraint(equalTo: self.topAnchor),
			colorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])
	}

	private func updateTapGestureRecognizer() {
		let hasTouchUpActions = allControlEvents.contains(.touchUpInside)
		if hasTouchUpActions {
			accessibilityTraits.insert(.button)
		} else {
			accessibilityTraits.remove(.button)
		}
		tapGestureRecognizer.isEnabled = hasTouchUpActions
	}

	private func updateBorderColor() {
		layer.borderColor = borderColor?.cgColor
	}

	private func updateDragDropInteraction() {
		isUserInteractionEnabled = isDragInteractionEnabled || isDropInteractionEnabled
		#if swift(>=5.3)
		if #available(iOS 14, *) {
			isUserInteractionEnabled = isUserInteractionEnabled || isContextMenuInteractionEnabled
		}
		#endif

		if isDragInteractionEnabled {
			addInteraction(dragInteraction)
		} else {
			removeInteraction(dragInteraction)
		}

		if isDropInteractionEnabled {
			addInteraction(dropInteraction)
		} else {
			removeInteraction(dropInteraction)
		}
	}

	/// :nodoc:
	override open func layoutSubviews() {
		super.layoutSubviews()

		layer.cornerRadius = frame.size.width / 2
		layer.shadowPath = CGPath(ellipseIn: bounds, transform: nil)
		colorView.layer.cornerRadius = layer.cornerRadius
	}

	/// :nodoc:
	override open func didMoveToWindow() {
		super.didMoveToWindow()
		let scale = window?.screen.scale ?? 1
		layer.borderWidth = (scale > 2 ? 2 : 1) / scale
	}

	/// :nodoc:
	override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateBorderColor()
	}

	/// :nodoc:
	open override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
		super.addTarget(target, action: action, for: controlEvents)
		updateTapGestureRecognizer()
	}

	/// :nodoc:
	@available(iOS 14, macCatalyst 14, *)
	open override func addAction(_ action: UIAction, for controlEvents: UIControl.Event) {
		super.addAction(action, for: controlEvents)
		updateTapGestureRecognizer()
	}

	/// :nodoc:
	open override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {
		super.removeTarget(target, action: action, for: controlEvents)
		updateTapGestureRecognizer()
	}

	/// :nodoc:
	@available(iOS 14, macCatalyst 14, *)
	open override func removeAction(_ action: UIAction, for controlEvents: UIControl.Event) {
		super.removeAction(action, for: controlEvents)
		updateTapGestureRecognizer()
	}

	/// :nodoc:
	@available(iOS 14, macCatalyst 14, *)
	open override func removeAction(identifiedBy actionIdentifier: UIAction.Identifier, for controlEvents: UIControl.Event) {
		super.removeAction(identifiedBy: actionIdentifier, for: controlEvents)
		updateTapGestureRecognizer()
	}

	@objc private func handleTapGestureRecognizerFired(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			sendActions(for: .touchUpInside)
		}
	}

}

/// :nodoc:
extension ColorWell { // UIResponder

	open override var canBecomeFirstResponder: Bool { true }

	open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		switch action {
		case #selector(copy(_:)), #selector(copyHex), #selector(copyRGB), #selector(copyHSL),
				 #selector(copyObjC), #selector(copySwift):
			return color != nil

		case #selector(paste(_:)):
			return UIPasteboard.general.hasColors || UIPasteboard.general.hasStrings

		default:
			return super.canPerformAction(action, withSender: sender)
		}
	}

	open override func copy(_ sender: Any?) {
		UIPasteboard.general.color = color
	}

	open override func paste(_ sender: Any?) {
		if let color = UIPasteboard.general.color ?? UIColor(propertyListValue: UIPasteboard.general.string ?? "") {
			self.color = color
			sendActions(for: .valueChanged)
		}
	}

	@objc private func copyHex(_ sender: Any?) {
		UIPasteboard.general.string = Color(uiColor: color!).hexString
	}

	@objc private func copyRGB(_ sender: Any?) {
		UIPasteboard.general.string = Color(uiColor: color!).rgbString
	}

	@objc private func copyHSL(_ sender: Any?) {
		UIPasteboard.general.string = Color(uiColor: color!).hslString
	}

	@objc private func copyObjC(_ sender: Any?) {
		UIPasteboard.general.string = Color(uiColor: color!).objcString
	}

	@objc private func copySwift(_ sender: Any?) {
		UIPasteboard.general.string = Color(uiColor: color!).swiftString
	}

}

/// :nodoc:
extension ColorWell: UIDragInteractionDelegate {

	/// :nodoc:
	public func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
		guard let color = color else {
			return []
		}
		let provider = NSItemProvider(object: color)
		let item = UIDragItem(itemProvider: provider)
		item.localObject = color
		return [item]
	}

}

/// :nodoc:
extension ColorWell: UIDropInteractionDelegate {

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
				self.color = color
				self.sendActions(for: .valueChanged)
			}
		}
	}

}

#if swift(>=5.5)
/// :nodoc:
@available(iOS 15, *)
extension ColorWell: UIToolTipInteractionDelegate {

	/// :nodoc:
	public func toolTipInteraction(_ interaction: UIToolTipInteraction, configurationAt point: CGPoint) -> UIToolTipConfiguration? {
		UIToolTipConfiguration(toolTip: contextMenuTitle)
	}

}
#endif

#if swift(>=5.3)
/// :nodoc:
@available(iOS 13, *)
extension ColorWell { // UIContextMenuInteractionDelegate

	/// :nodoc:
	open override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: color, previewProvider: nil) { items in
			var children = [UIMenuElement]()
			if isCatalyst {
				children += [
					UIMenu(title: "", options: .displayInline, children: [
						UICommand(title: self.contextMenuTitle,
											action: #selector(self.doesNotRecognizeSelector(_:)),
											attributes: .disabled)
					])
				]
			}
			children += items

			var objcImageName = "chevron.left.slash.chevron.right"
			var swiftImageName = "chevron.left.slash.chevron.right"
			if #available(iOS 14, *) {
				objcImageName = "curlybraces"
				swiftImageName = "swift"
			}
			children += [
				UIMenu(title: "", options: .displayInline, children: [
					UICommand(title: "Copy as Hex",
										image: UIImage(systemName: "number"),
										action: #selector(self.copyHex(_:))),
					UICommand(title: "Copy as RGB",
										image: UIImage(systemName: "r.circle"),
										action: #selector(self.copyRGB(_:))),
					UICommand(title: "Copy as HSL",
										image: UIImage(systemName: "h.circle"),
										action: #selector(self.copyHSL(_:))),
					UICommand(title: "Copy as Objective-C",
										image: UIImage(systemName: objcImageName),
										action: #selector(self.copyObjC(_:))),
					UICommand(title: "Copy as Swift",
										image: UIImage(systemName: swiftImageName),
										action: #selector(self.copySwift(_:))),
				])
			]
			return UIMenu(title: self.contextMenuTitle, children: children)
		}
	}

}
#endif

/// Deprecated. Use `ColorWell` instead.
@available(*, deprecated, renamed: "ColorWell")
@objc(HBColorPickerCircleView)
open class ColorPickerCircleView: ColorWell {}
