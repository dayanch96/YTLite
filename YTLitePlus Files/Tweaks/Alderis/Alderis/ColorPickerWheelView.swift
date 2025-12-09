//
//  ColorPickerMapView.swift
//  Alderis
//
//  Created by Adam Demasi on 14/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal protocol ColorPickerWheelViewDelegate: AnyObject {
	func colorPickerWheelView(didSelectColor color: Color)
}

internal class ColorPickerWheelView: UIView {

	weak var delegate: ColorPickerWheelViewDelegate?

	var color: Color {
		didSet { updateColor() }
	}

	private var containerView: UIView!
	private var wheelView: ColorPickerWheelInnerView!
	private var selectionView: ColorWell!
	private var selectionViewXConstraint: NSLayoutConstraint!
	private var selectionViewYConstraint: NSLayoutConstraint!
	private var selectionViewFingerDownConstraint: NSLayoutConstraint!

	private var isFingerDown = false
	private let touchDownFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
	private let touchUpFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

	init(color: Color) {
		self.color = color
		super.init(frame: .zero)

		containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.clipsToBounds = true
		addSubview(containerView)

		containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gestureRecognizerFired(_:))))
		containerView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(gestureRecognizerFired(_:))))
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizerFired(_:)))
		panGestureRecognizer.maximumNumberOfTouches = 1
		containerView.addGestureRecognizer(panGestureRecognizer)

		wheelView = ColorPickerWheelInnerView()
		wheelView.translatesAutoresizingMaskIntoConstraints = false
		wheelView.handleLayout = { [weak self] in self?.setNeedsLayout() }
		containerView.addSubview(wheelView)

		selectionView = ColorWell()
		selectionView.translatesAutoresizingMaskIntoConstraints = false
		selectionView.isDragInteractionEnabled = false
		selectionView.isDropInteractionEnabled = false
		#if swift(>=5.3)
		if #available(iOS 14, *) {
			selectionView.isContextMenuInteractionEnabled = false
		}
		#endif
		containerView.addSubview(selectionView)

		selectionViewXConstraint = selectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor)
		selectionViewYConstraint = selectionView.topAnchor.constraint(equalTo: containerView.topAnchor)
		// https://www.youtube.com/watch?v=Qs8kDiOwPBA
		selectionViewFingerDownConstraint = selectionView.widthAnchor.constraint(equalToConstant: 56)
		let selectionViewNormalConstraint = selectionView.widthAnchor.constraint(equalToConstant: UIFloat(24))
		selectionViewNormalConstraint.priority = .defaultHigh

		// Remove minimum width constraint configured by ColorWell internally
		let selectionWidthConstraint = selectionView.constraints.first { $0.firstAnchor == selectionView.widthAnchor }
		selectionWidthConstraint?.isActive = false

		NSLayoutConstraint.activate([
			containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			containerView.topAnchor.constraint(equalTo: self.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor, constant: UIFloat(30)),

			wheelView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIFloat(30)),
			wheelView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: UIFloat(-30)),
			wheelView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIFloat(15)),
			wheelView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: UIFloat(-15)),

			selectionViewXConstraint,
			selectionViewYConstraint,
			selectionViewNormalConstraint,
			selectionView.heightAnchor.constraint(equalTo: selectionView.widthAnchor)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		updateSelectionPoint()
	}

	private func updateColor() {
		wheelView.brightness = color.brightness
		selectionView.backgroundColor = color.uiColor
		updateSelectionPoint()
	}

	private func updateSelectionPoint() {
		let colorPoint = pointForColor(color, in: wheelView.frame.size)
		let point = CGPoint(x: wheelView.frame.origin.x + colorPoint.x - (selectionView.frame.size.width / 2),
												y: min(
													frame.size.height - selectionView.frame.size.height - 1,
													max(1, wheelView.frame.origin.y + colorPoint.y - (selectionView.frame.size.height / 2))
												))
		selectionViewXConstraint.constant = point.x
		selectionViewYConstraint.constant = point.y
	}

	private func colorAt(position: CGPoint, in size: CGSize) -> Color {
		let point = CGPoint(x: (size.width / 2) - position.x,
												y: (size.height / 2) - position.y)
		let h = 180 + round(atan2(point.y, point.x) * (180 / .pi))
		let handleRange = size.width / 2
		let handleDistance = min(sqrt(point.x * point.x + point.y * point.y), handleRange)
		let s = round(100 / handleRange * handleDistance)
		return Color(hue: h / 360, saturation: s / 100, brightness: color.brightness, alpha: 1)
	}

	private func pointForColor(_ color: Color, in size: CGSize) -> CGPoint {
		let handleRange = size.width / 2
		let handleAngle = (color.hue * 360) * (.pi / 180)
		let handleDistance = color.saturation * handleRange
		return CGPoint(x: (size.width / 2) + handleDistance * cos(handleAngle),
									 y: (size.height / 2) + handleDistance * sin(handleAngle))
	}

	@objc private func gestureRecognizerFired(_ sender: UIGestureRecognizer) {
		switch sender.state {
		case .began, .changed, .ended:
			var location = sender.location(in: containerView)
			location.x -= wheelView.frame.origin.x
			location.y -= wheelView.frame.origin.y
			color = colorAt(position: location, in: wheelView.frame.size)
			delegate?.colorPickerWheelView(didSelectColor: color)
		case .possible, .cancelled, .failed:
			break
		@unknown default:
			break
		}

		if sender is UITapGestureRecognizer {
			return
		}

		switch sender.state {
		case .began, .ended, .cancelled:
			isFingerDown = sender.state == .began
			selectionViewFingerDownConstraint.isActive = isFingerDown && !isCatalyst
			updateSelectionPoint()
			UIView.animate(withDuration: 0.2, animations: {
				self.containerView.layoutIfNeeded()
				self.updateSelectionPoint()
			}, completion: { _ in
				self.updateSelectionPoint()
			})
			if sender.state == .began {
				touchDownFeedbackGenerator.impactOccurred()
			} else {
				touchUpFeedbackGenerator.impactOccurred()
			}
		case .possible, .changed, .failed:
			break
		@unknown default:
			break
		}
	}

}

private class ColorPickerWheelInnerView: UIView {
	private var brightnessView: UIView!

	var brightness: CGFloat {
		get { 1 - brightnessView.alpha }
		set { brightnessView.alpha = 1 - newValue }
	}

	var handleLayout: (() -> Void)!

	private var saturationMask: GradientView!

	override init(frame: CGRect) {
		super.init(frame: frame)

		clipsToBounds = true

		let hueView = GradientView()
		hueView.translatesAutoresizingMaskIntoConstraints = false
		hueView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		hueView.gradientLayer.type = .conic
		hueView.gradientLayer.colors = Color.Component.hue.sliderTintColor(for: Color(red: 1, green: 0, blue: 0, alpha: 1)).map(\.uiColor.cgColor)
		hueView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		hueView.gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
		hueView.gradientLayer.transform = CATransform3DMakeRotation(0.5 * .pi, 0, 0, 1)
		addSubview(hueView)

		let saturationView = UIView()
		saturationView.translatesAutoresizingMaskIntoConstraints = false
		saturationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		saturationView.backgroundColor = .white
		addSubview(saturationView)

		saturationMask = GradientView()
		saturationMask.gradientLayer.type = .radial
		saturationMask.gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
		saturationMask.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		saturationMask.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		saturationView.mask = saturationMask

		brightnessView = UIView()
		brightnessView.translatesAutoresizingMaskIntoConstraints = false
		brightnessView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		brightnessView.backgroundColor = .black
		addSubview(brightnessView)
	}

	convenience init() {
		self.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = frame.size.height / 2
		saturationMask.frame = bounds
		handleLayout()
	}
}
