//
//  ColorPickerSlider.swift
//  Alderis
//
//  Created by Kabir Oberai on 28/03/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerSliderBase: UIControl {

	var overrideSmartInvert: Bool {
		didSet {
			slider.accessibilityIgnoresInvertColors = overrideSmartInvert
		}
	}

	let stackView: UIStackView
	let slider: ColorSlider

	var value: CGFloat {
		get { CGFloat(slider.value) }
		set { slider.value = Float(newValue) }
	}

	init(overrideSmartInvert: Bool) {
		self.overrideSmartInvert = overrideSmartInvert

		slider = ColorSlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.accessibilityIgnoresInvertColors = overrideSmartInvert

		stackView = UIStackView(arrangedSubviews: [slider])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill

		super.init(frame: .zero)

		slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc internal func sliderChanged() {
		sendActions(for: .valueChanged)
	}

}

internal protocol ColorPickerSliderProtocol: ColorPickerSliderBase {
	func setColor(_ color: Color)
	func apply(to color: inout Color)
}

internal typealias ColorPickerSlider = ColorPickerSliderBase & ColorPickerSliderProtocol

internal class ColorPickerComponentSlider: ColorPickerSlider {

	let component: Color.Component

	init(component: Color.Component, overrideSmartInvert: Bool) {
		self.component = component
		super.init(overrideSmartInvert: overrideSmartInvert)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setColor(_ color: Color) {
		value = color[keyPath: component.keyPath]
		slider.color = color.uiColor
		slider.gradientColors = component.sliderTintColor(for: color).map(\.uiColor)
	}

	func apply(to color: inout Color) {
		color[keyPath: component.keyPath] = value
	}

}

internal class ColorSlider: UISlider {
	private let thumbImage = UIGraphicsImageRenderer(size: CGSize(width: 26, height: 26)).image { _ in }

	var gradientColors = [UIColor]() {
		didSet { gradientView.gradientLayer.colors = gradientColors.map(\.cgColor) }
	}

	var color: UIColor? {
		get { selectionView?.color }
		set { selectionView?.color = newValue }
	}

	private var checkerboardView: UIView!
	private var gradientView: GradientView!

	private var selectionView: ColorWell?
	private var selectionViewXConstraint: NSLayoutConstraint?
	private var valueObserver: NSKeyValueObservation?

	override init(frame: CGRect) {
		super.init(frame: frame)

		#if swift(>=5.5)
		var useSliderTrack = !isCatalystMac
		if #available(iOS 15, *) {
			preferredBehavioralStyle = .pad
			useSliderTrack = true
		}
		#else
		let useSliderTrack = true
		#endif
		if useSliderTrack {
			setMinimumTrackImage(UIImage(), for: .normal)
			setMaximumTrackImage(UIImage(), for: .normal)
			setThumbImage(thumbImage, for: .normal)
		}

		checkerboardView = UIView()
		checkerboardView.translatesAutoresizingMaskIntoConstraints = false
		checkerboardView.backgroundColor = Assets.checkerboardPatternColor
		checkerboardView.clipsToBounds = true
		if #available(iOS 13, *) {
			checkerboardView.layer.cornerCurve = .continuous
		}
		insertSubview(checkerboardView, at: 0)

		gradientView = GradientView()
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientView.gradientLayer.endPoint = CGPoint(x: 1, y: 0)
		gradientView.gradientLayer.allowsGroupOpacity = false
		checkerboardView.addSubview(gradientView)

		NSLayoutConstraint.activate([
			checkerboardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: UIFloat(-3)),
			checkerboardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: UIFloat(3)),
			checkerboardView.topAnchor.constraint(equalTo: self.topAnchor, constant: -1),
			checkerboardView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1),

			gradientView.leadingAnchor.constraint(equalTo: checkerboardView.leadingAnchor),
			gradientView.trailingAnchor.constraint(equalTo: checkerboardView.trailingAnchor),
			gradientView.topAnchor.constraint(equalTo: checkerboardView.topAnchor),
			gradientView.bottomAnchor.constraint(equalTo: checkerboardView.bottomAnchor),
		])

		if useSliderTrack {
			let selectionView = ColorWell()
			selectionView.translatesAutoresizingMaskIntoConstraints = false
			selectionView.isDragInteractionEnabled = false
			selectionView.isDropInteractionEnabled = false
			#if swift(>=5.3)
			if #available(iOS 14, *) {
				selectionView.isContextMenuInteractionEnabled = false
			}
			#endif
			insertSubview(selectionView, aboveSubview: checkerboardView)
			self.selectionView = selectionView

			selectionViewXConstraint = selectionView.leadingAnchor.constraint(equalTo: checkerboardView.leadingAnchor)

			// Remove minimum width constraint configured by ColorWell internally
			let selectionWidthConstraint = selectionView.constraints.first { $0.firstAnchor == selectionView.widthAnchor }
			selectionWidthConstraint?.isActive = false

			NSLayoutConstraint.activate([
				selectionViewXConstraint!,
				selectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
				selectionView.widthAnchor.constraint(equalToConstant: UIFloat(24))
			])

			valueObserver = observe(\.value) { _, _ in self.valueChanged() }
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		checkerboardView.layer.cornerRadius = checkerboardView.frame.size.height / 2
		valueChanged()
	}

	private func valueChanged() {
		guard let selectionView = selectionView,
					let selectionViewXConstraint = selectionViewXConstraint else {
			return
		}
		let spacing = frame.size.height - selectionView.frame.size.height
		selectionViewXConstraint.constant = (spacing / 2) + ((frame.size.width - selectionView.frame.size.width - spacing) * CGFloat(value))
	}
}
