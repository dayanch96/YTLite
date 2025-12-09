//
//  ColorPickerSwatchViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 13/3/20.
//  Copyright © 2020 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerSwatchViewController: ColorPickerTabViewController {

	private class ColorLayer: CALayer {
		let color: Color
		init(color: Color) {
			self.color = color
			super.init()
			backgroundColor = color.uiColor.cgColor
		}
		override init(layer: Any) {
			color = Color(white: 1, alpha: 1)
			super.init(layer: layer)
		}
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	}

	static let title = "Swatch"
	static let imageName = "square.grid.4x3.fill"

	static let colorSwatch = [
		[
			Color(hue: 0.000000, saturation: 0.000000, brightness: 1.000000, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.921569, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.839216, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.760784, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.678431, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.600000, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.521569, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.439216, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.360784, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.278431, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.200000, alpha: 1),
			Color(hue: 0.000000, saturation: 0.000000, brightness: 0.000000, alpha: 1),
		],
		[
			Color(hue: 0.542793, saturation: 1.000000, brightness: 0.290196, alpha: 1),
			Color(hue: 0.612403, saturation: 0.988506, brightness: 0.341176, alpha: 1),
			Color(hue: 0.703704, saturation: 0.915255, brightness: 0.231373, alpha: 1),
			Color(hue: 0.787878, saturation: 0.901640, brightness: 0.239216, alpha: 1),
			Color(hue: 0.937107, saturation: 0.883333, brightness: 0.235294, alpha: 1),
			Color(hue: 0.010989, saturation: 0.989130, brightness: 0.360784, alpha: 1),
			Color(hue: 0.051852, saturation: 1.000000, brightness: 0.352941, alpha: 1),
			Color(hue: 0.096591, saturation: 1.000000, brightness: 0.345098, alpha: 1),
			Color(hue: 0.118217, saturation: 1.000000, brightness: 0.337255, alpha: 1),
			Color(hue: 0.158497, saturation: 1.000000, brightness: 0.400000, alpha: 1),
			Color(hue: 0.179012, saturation: 0.952941, brightness: 0.333333, alpha: 1),
			Color(hue: 0.251773, saturation: 0.758064, brightness: 0.243137, alpha: 1),
		],
		[
			Color(hue: 0.539604, saturation: 1.000000, brightness: 0.396078, alpha: 1),
			Color(hue: 0.603825, saturation: 0.991870, brightness: 0.482353, alpha: 1),
			Color(hue: 0.703704, saturation: 0.878049, brightness: 0.321569, alpha: 1),
			Color(hue: 0.789473, saturation: 0.853933, brightness: 0.349020, alpha: 1),
			Color(hue: 0.939614, saturation: 0.811765, brightness: 0.333333, alpha: 1),
			Color(hue: 0.021629, saturation: 1.000000, brightness: 0.513725, alpha: 1),
			Color(hue: 0.055555, saturation: 1.000000, brightness: 0.482353, alpha: 1),
			Color(hue: 0.101093, saturation: 1.000000, brightness: 0.478431, alpha: 1),
			Color(hue: 0.122222, saturation: 1.000000, brightness: 0.470588, alpha: 1),
			Color(hue: 0.158273, saturation: 0.985816, brightness: 0.552941, alpha: 1),
			Color(hue: 0.177469, saturation: 0.915254, brightness: 0.462745, alpha: 1),
			Color(hue: 0.251366, saturation: 0.701148, brightness: 0.341176, alpha: 1),
		],
		[
			Color(hue: 0.538732, saturation: 0.993007, brightness: 0.560784, alpha: 1),
			Color(hue: 0.601578, saturation: 1.000000, brightness: 0.662745, alpha: 1),
			Color(hue: 0.719697, saturation: 0.924370, brightness: 0.466667, alpha: 1),
			Color(hue: 0.788333, saturation: 0.806452, brightness: 0.486275, alpha: 1),
			Color(hue: 0.938596, saturation: 0.785124, brightness: 0.474510, alpha: 1),
			Color(hue: 0.023941, saturation: 1.000000, brightness: 0.709804, alpha: 1),
			Color(hue: 0.059730, saturation: 1.000000, brightness: 0.678431, alpha: 1),
			Color(hue: 0.102564, saturation: 1.000000, brightness: 0.662745, alpha: 1),
			Color(hue: 0.123232, saturation: 0.993976, brightness: 0.650980, alpha: 1),
			Color(hue: 0.159864, saturation: 1.000000, brightness: 0.768627, alpha: 1),
			Color(hue: 0.177704, saturation: 0.915151, brightness: 0.647059, alpha: 1),
			Color(hue: 0.255020, saturation: 0.680328, brightness: 0.478431, alpha: 1),
		],
		[
			Color(hue: 0.537037, saturation: 1.000000, brightness: 0.705882, alpha: 1),
			Color(hue: 0.599688, saturation: 1.000000, brightness: 0.839216, alpha: 1),
			Color(hue: 0.706284, saturation: 0.824324, brightness: 0.580392, alpha: 1),
			Color(hue: 0.785333, saturation: 0.791139, brightness: 0.619608, alpha: 1),
			Color(hue: 0.938746, saturation: 0.764707, brightness: 0.600000, alpha: 1),
			Color(hue: 0.026549, saturation: 1.000000, brightness: 0.886275, alpha: 1),
			Color(hue: 0.061927, saturation: 1.000000, brightness: 0.854902, alpha: 1),
			Color(hue: 0.103175, saturation: 0.995261, brightness: 0.827451, alpha: 1),
			Color(hue: 0.125000, saturation: 0.995215, brightness: 0.819608, alpha: 1),
			Color(hue: 0.160544, saturation: 1.000000, brightness: 0.960784, alpha: 1),
			Color(hue: 0.179211, saturation: 0.889952, brightness: 0.819608, alpha: 1),
			Color(hue: 0.253968, saturation: 0.668789, brightness: 0.615686, alpha: 1),
		],
		[
			Color(hue: 0.542438, saturation: 1.000000, brightness: 0.847059, alpha: 1),
			Color(hue: 0.603018, saturation: 1.000000, brightness: 0.996078, alpha: 1),
			Color(hue: 0.716435, saturation: 0.808989, brightness: 0.698039, alpha: 1),
			Color(hue: 0.792237, saturation: 0.776596, brightness: 0.737255, alpha: 1),
			Color(hue: 0.942857, saturation: 0.756756, brightness: 0.725490, alpha: 1),
			Color(hue: 0.030627, saturation: 0.917647, brightness: 1.000000, alpha: 1),
			Color(hue: 0.069281, saturation: 1.000000, brightness: 1.000000, alpha: 1),
			Color(hue: 0.111549, saturation: 0.996078, brightness: 1.000000, alpha: 1),
			Color(hue: 0.131093, saturation: 1.000000, brightness: 0.992157, alpha: 1),
			Color(hue: 0.164021, saturation: 0.744094, brightness: 0.996078, alpha: 1),
			Color(hue: 0.184162, saturation: 0.766949, brightness: 0.925490, alpha: 1),
			Color(hue: 0.260163, saturation: 0.657754, brightness: 0.733333, alpha: 1),
		],
		[
			Color(hue: 0.535193, saturation: 0.996032, brightness: 0.988235, alpha: 1),
			Color(hue: 0.601190, saturation: 0.771653, brightness: 0.996078, alpha: 1),
			Color(hue: 0.707665, saturation: 0.795745, brightness: 0.921569, alpha: 1),
			Color(hue: 0.786096, saturation: 0.769547, brightness: 0.952941, alpha: 1),
			Color(hue: 0.938597, saturation: 0.743478, brightness: 0.901961, alpha: 1),
			Color(hue: 0.017143, saturation: 0.686275, brightness: 1.000000, alpha: 1),
			Color(hue: 0.056466, saturation: 0.717647, brightness: 1.000000, alpha: 1),
			Color(hue: 0.102094, saturation: 0.751968, brightness: 0.996078, alpha: 1),
			Color(hue: 0.122396, saturation: 0.755906, brightness: 0.996078, alpha: 1),
			Color(hue: 0.157658, saturation: 0.580392, brightness: 1.000000, alpha: 1),
			Color(hue: 0.179952, saturation: 0.577406, brightness: 0.937255, alpha: 1),
			Color(hue: 0.254310, saturation: 0.549763, brightness: 0.827451, alpha: 1),
		],
		[
			Color(hue: 0.537255, saturation: 0.674603, brightness: 0.988235, alpha: 1),
			Color(hue: 0.605516, saturation: 0.545098, brightness: 1.000000, alpha: 1),
			Color(hue: 0.719048, saturation: 0.688976, brightness: 0.996078, alpha: 1),
			Color(hue: 0.790419, saturation: 0.657481, brightness: 0.996078, alpha: 1),
			Color(hue: 0.940000, saturation: 0.525210, brightness: 0.933333, alpha: 1),
			Color(hue: 0.013333, saturation: 0.490196, brightness: 1.000000, alpha: 1),
			Color(hue: 0.051282, saturation: 0.509804, brightness: 1.000000, alpha: 1),
			Color(hue: 0.098039, saturation: 0.533333, brightness: 1.000000, alpha: 1),
			Color(hue: 0.120098, saturation: 0.533333, brightness: 1.000000, alpha: 1),
			Color(hue: 0.157321, saturation: 0.419608, brightness: 1.000000, alpha: 1),
			Color(hue: 0.180135, saturation: 0.409091, brightness: 0.949020, alpha: 1),
			Color(hue: 0.256097, saturation: 0.371041, brightness: 0.866667, alpha: 1),
		],
		[
			Color(hue: 0.540881, saturation: 0.418972, brightness: 0.992157, alpha: 1),
			Color(hue: 0.607954, saturation: 0.345098, brightness: 1.000000, alpha: 1),
			Color(hue: 0.720760, saturation: 0.448818, brightness: 0.996078, alpha: 1),
			Color(hue: 0.790124, saturation: 0.425197, brightness: 0.996078, alpha: 1),
			Color(hue: 0.941667, saturation: 0.327869, brightness: 0.956863, alpha: 1),
			Color(hue: 0.012500, saturation: 0.313725, brightness: 1.000000, alpha: 1),
			Color(hue: 0.051587, saturation: 0.329412, brightness: 1.000000, alpha: 1),
			Color(hue: 0.093869, saturation: 0.341176, brightness: 1.000000, alpha: 1),
			Color(hue: 0.116279, saturation: 0.338582, brightness: 0.996078, alpha: 1),
			Color(hue: 0.157143, saturation: 0.274510, brightness: 1.000000, alpha: 1),
			Color(hue: 0.179687, saturation: 0.259109, brightness: 0.968627, alpha: 1),
			Color(hue: 0.254902, saturation: 0.219828, brightness: 0.909804, alpha: 1),
		],
		[
			Color(hue: 0.548077, saturation: 0.203922, brightness: 1.000000, alpha: 1),
			Color(hue: 0.609848, saturation: 0.172549, brightness: 1.000000, alpha: 1),
			Color(hue: 0.716981, saturation: 0.208661, brightness: 0.996078, alpha: 1),
			Color(hue: 0.783019, saturation: 0.207843, brightness: 1.000000, alpha: 1),
			Color(hue: 0.942983, saturation: 0.152611, brightness: 0.976471, alpha: 1),
			Color(hue: 0.012821, saturation: 0.152941, brightness: 1.000000, alpha: 1),
			Color(hue: 0.048781, saturation: 0.160784, brightness: 1.000000, alpha: 1),
			Color(hue: 0.093023, saturation: 0.168627, brightness: 1.000000, alpha: 1),
			Color(hue: 0.115080, saturation: 0.164706, brightness: 1.000000, alpha: 1),
			Color(hue: 0.156566, saturation: 0.129921, brightness: 0.996078, alpha: 1),
			Color(hue: 0.182796, saturation: 0.123999, brightness: 0.980392, alpha: 1),
			Color(hue: 0.262820, saturation: 0.109243, brightness: 0.933333, alpha: 1),
		]
	]

	let colors = ColorPickerSwatchViewController.colorSwatch

	private var colorRows = [[ColorLayer]]()
	private var colorDict = [String: ColorLayer]()

	var containerView: UIView!
	var selectionView: UIView!
	var containerViewHeightConstraint: NSLayoutConstraint!
	var selectionViewWidthConstraint: NSLayoutConstraint!
	var selectionViewXConstraint: NSLayoutConstraint!
	var selectionViewYConstraint: NSLayoutConstraint!

	override func viewDidLoad() {
		super.viewDidLoad()

		containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.accessibilityIgnoresInvertColors = configuration.overrideSmartInvert
		view.addSubview(containerView)

		for row in colors {
			var colorRow = [ColorLayer]()
			for color in row {
				let colorLayer = ColorLayer(color: color)
				containerView.layer.addSublayer(colorLayer)
				colorDict[color.hexString()] = colorLayer
				colorRow.append(colorLayer)
			}
			colorRows.append(colorRow)
		}

		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gestureRecognizerFired(_:))))
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizerFired(_:)))
		panGestureRecognizer.maximumNumberOfTouches = 1
		view.addGestureRecognizer(panGestureRecognizer)

		selectionView = UIView()
		selectionView.translatesAutoresizingMaskIntoConstraints = false
		selectionView.isUserInteractionEnabled = false
		selectionView.layer.borderColor = UIColor.white.cgColor
		selectionView.layer.borderWidth = 2
		selectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
		selectionView.layer.shadowOpacity = 1
		selectionView.layer.shadowColor = UIColor(white: 0, alpha: 0.1).cgColor
		view.addSubview(selectionView)

		containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
		selectionViewWidthConstraint = selectionView.widthAnchor.constraint(equalToConstant: UIFloat(20))
		let selectionViewBaseXConstraint = selectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
		selectionViewBaseXConstraint.priority = .defaultLow
		let selectionViewBaseYConstraint = selectionView.topAnchor.constraint(equalTo: view.topAnchor)
		selectionViewBaseYConstraint.priority = .defaultLow
		selectionViewXConstraint = selectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
		selectionViewYConstraint = selectionView.topAnchor.constraint(equalTo: view.topAnchor)

		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			containerView.topAnchor.constraint(equalTo: view.topAnchor),
			containerView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor),
			containerViewHeightConstraint,

			selectionViewWidthConstraint,
			selectionView.heightAnchor.constraint(equalTo: selectionView.widthAnchor),
			selectionViewBaseXConstraint,
			selectionViewBaseYConstraint,
			selectionViewXConstraint,
			selectionViewYConstraint
		])

		colorDidChange()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		var x: CGFloat = 0, y: CGFloat = 0
		let size = view.frame.size.width / CGFloat(colors[0].count)
		for row in colorRows {
			x = 0
			for item in row {
				item.frame = CGRect(x: x * size, y: y * size, width: size, height: size)
				x += 1
			}
			y += 1
		}

		containerViewHeightConstraint.constant = y * size
		selectionViewWidthConstraint.constant = size
		UIView.performWithoutAnimation {
			colorDidChange()
		}
	}

	@objc private func gestureRecognizerFired(_ sender: UIGestureRecognizer) {
		switch sender.state {
		case .began, .changed, .ended:
			let location = sender.location(in: containerView)
			guard let colorView = containerView.layer.hitTest(location) as? ColorLayer else {
				return
			}
			self.setColor(colorView.color)
		case .possible, .cancelled, .failed:
			break
		@unknown default:
			break
		}
	}

	func setSelection(to colorLayer: CALayer?) {
		let wasHidden = selectionView.isHidden
		selectionView.isHidden = colorLayer == nil
		selectionViewXConstraint.constant = colorLayer?.frame.origin.x ?? 0
		selectionViewYConstraint.constant = colorLayer?.frame.origin.y ?? 0
		if wasHidden {
			view.layoutIfNeeded()
		} else {
			UIView.animate(withDuration: 0.2) {
				self.view.layoutIfNeeded()
			}
		}
	}

	override func colorDidChange() {
		guard selectionView != nil else { return }
		setSelection(to: colorDict[color.hexString()])
	}

}
