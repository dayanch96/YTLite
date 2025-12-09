//
//  ColorPickerAccessibilityViewController.swift
//  Alderis
//
//  Created by Adam Demasi on 8/5/2022.
//  Copyright © 2022 HASHBANG Productions. All rights reserved.
//

import UIKit

internal class ColorPickerAccessibilityViewController: ColorPickerTabViewController {

	static let title = "Contrast Checker"
	static let imageName = "circle.righthalf.fill"

	private static let percentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		return formatter
	}()

	private var backgroundMode: AccessibilityContrastSelector.Mode = .white {
		didSet { colorDidChange() }
	}
	private var foregroundMode: AccessibilityContrastSelector.Mode = .color {
		didSet { colorDidChange() }
	}

	private var scrollView: UIScrollView!

	private var demoContainerView: UIView!
	private var demoLabels: [UIView]!

	private var contrastStackView: UIStackView!
	private var contrastRatioLabel: UILabel!
	private var aaComplianceLabel: AccessibilityComplianceLabel!
	private var aaaComplianceLabel: AccessibilityComplianceLabel!

	private var backgroundSelector: AccessibilityContrastSelector!
	private var foregroundSelector: AccessibilityContrastSelector!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Catalyst in iPad UI mode scales all UI down to 77%, so we cancel out the scaling (as well as
		// we possibly can, given scaling down is throwing away quality) for the demo labels.
		let scaleFactor: CGFloat = isCatalystPad ? 1 / 0.77 : 1

		let demoTitleLabel = UILabel()
		demoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		demoTitleLabel.font = .systemFont(ofSize: 18 * scaleFactor, weight: .semibold)
		demoTitleLabel.text = "Size 18 • Contrast Checker"

		let demoImageView = UIImageView(image: Assets.systemImage(named: "sparkles", font: demoTitleLabel.font, scale: .small))
		demoImageView.translatesAutoresizingMaskIntoConstraints = false

		let titleStackView = UIStackView(arrangedSubviews: [demoImageView, demoTitleLabel])
		titleStackView.translatesAutoresizingMaskIntoConstraints = false
		titleStackView.spacing = UIFloat(6)
		titleStackView.alignment = .center

		let demoSubtitleLabel = UILabel()
		demoSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		demoSubtitleLabel.font = .systemFont(ofSize: 14 * scaleFactor, weight: .medium)
		demoSubtitleLabel.text = "Size 14 • Contrast ratios are a measure of how easily text and images can be read, especially by people with lower vision."
		demoSubtitleLabel.numberOfLines = 0

		let demoTextLabel = TextViewLabel()
		demoTextLabel.translatesAutoresizingMaskIntoConstraints = false
		demoTextLabel.linkTextAttributes = [
			.underlineStyle: NSUnderlineStyle.single.rawValue
		]
		let explainerText = "Size 12 • Learn more about minimum (AA) and enhanced (AAA) contrast."
		let attributedString = NSMutableAttributedString(string: explainerText,
																										 attributes: [
																											.font: UIFont.systemFont(ofSize: 12 * scaleFactor, weight: .regular)
																										 ])
		attributedString.addAttribute(.link,
																	value: URL(string: "https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum")!,
																	range: (attributedString.string as NSString).range(of: "minimum (AA)"))
		attributedString.addAttribute(.link,
																	value: URL(string: "https://www.w3.org/WAI/WCAG21/Understanding/contrast-enhanced")!,
																	range: (attributedString.string as NSString).range(of: "enhanced (AAA)"))
		demoTextLabel.attributedText = attributedString

		demoLabels = [demoTitleLabel, demoSubtitleLabel, demoTextLabel]

		let demoStackView = UIStackView(arrangedSubviews: [titleStackView, demoSubtitleLabel, demoTextLabel])
		demoStackView.translatesAutoresizingMaskIntoConstraints = false
		demoStackView.axis = .vertical
		demoStackView.alignment = .leading
		demoStackView.spacing = UIFloat(8)

		demoContainerView = UIView()
		demoContainerView.translatesAutoresizingMaskIntoConstraints = false
		demoContainerView.layer.cornerRadius = 12
		if #available(iOS 13, *) {
			demoContainerView.layer.cornerCurve = .continuous
		}
		demoContainerView.addSubview(demoStackView)

		contrastRatioLabel = UILabel()
		contrastRatioLabel.translatesAutoresizingMaskIntoConstraints = false
		contrastRatioLabel.font = .systemFont(ofSize: UIFloat(16), weight: .medium)

		aaComplianceLabel = AccessibilityComplianceLabel(text: "AA")
		aaaComplianceLabel = AccessibilityComplianceLabel(text: "AAA")

		let complianceStackView = UIStackView(arrangedSubviews: [UIView(), aaComplianceLabel, aaaComplianceLabel])
		complianceStackView.translatesAutoresizingMaskIntoConstraints = false
		complianceStackView.spacing = UIFloat(12)

		contrastStackView = UIStackView(arrangedSubviews: [contrastRatioLabel, complianceStackView])
		contrastStackView.translatesAutoresizingMaskIntoConstraints = false
		contrastStackView.spacing = UIFloat(8)

		backgroundSelector = AccessibilityContrastSelector(text: "Background", value: backgroundMode)
		backgroundSelector.handleChange = { self.backgroundMode = $0 }

		foregroundSelector = AccessibilityContrastSelector(text: "Foreground", value: foregroundMode)
		foregroundSelector.handleChange = { self.foregroundMode = $0 }

		scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.alwaysBounceVertical = false
		view.addSubview(scrollView)

		let rootStackView = UIStackView(arrangedSubviews: [demoContainerView, UIView(), contrastStackView, backgroundSelector, foregroundSelector, UIView()])
		rootStackView.translatesAutoresizingMaskIntoConstraints = false
		rootStackView.axis = .vertical
		rootStackView.alignment = .fill
		rootStackView.distribution = .fill
		rootStackView.spacing = UIFloat(10)
		scrollView.addSubview(rootStackView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			rootStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: UIFloat(15)),
			rootStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: UIFloat(-15)),
			rootStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: UIFloat(15)),
			rootStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: UIFloat(-15)),
			rootStackView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor, constant: UIFloat(-30)),
			scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			scrollView.contentLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

			demoStackView.topAnchor.constraint(equalTo: demoContainerView.topAnchor, constant: UIFloat(16)),
			demoStackView.bottomAnchor.constraint(equalTo: demoContainerView.bottomAnchor, constant: UIFloat(-17)),
			demoStackView.leadingAnchor.constraint(equalTo: demoContainerView.leadingAnchor, constant: UIFloat(20)),
			demoStackView.trailingAnchor.constraint(equalTo: demoContainerView.trailingAnchor, constant: UIFloat(-20)),

			contrastStackView.heightAnchor.constraint(greaterThanOrEqualTo: backgroundSelector.heightAnchor),
			contrastStackView.heightAnchor.constraint(greaterThanOrEqualTo: foregroundSelector.heightAnchor)
		])

		colorDidChange()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		scrollView.flashScrollIndicators()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		contrastStackView.axis = view.frame.size.width > UIFloat(300) ? .horizontal : .vertical
	}

	override func colorDidChange() {
		let backgroundColor = backgroundMode.color(withColor: color)
		let foregroundColor = foregroundMode.color(withColor: color)

		if backgroundColor == foregroundColor {
			// Change one or the other to not be identical
			if backgroundMode == foregroundMode {
				switch backgroundMode {
				case .black, .white: foregroundMode = .color
				default:             foregroundMode = .white
				}
			} else {
				if foregroundMode == .color {
					backgroundMode = backgroundColor == .white ? .black : .white
				} else if backgroundMode == .color {
					foregroundMode = foregroundColor == .white ? .black : .white
				}
			}
			return
		}

		backgroundSelector.value = backgroundMode
		foregroundSelector.value = foregroundMode

		demoContainerView.backgroundColor = backgroundColor.uiColor
		demoContainerView.tintColor = foregroundColor.uiColor
		for label in demoLabels {
			if let label = label as? UILabel {
				label.textColor = foregroundColor.uiColor
			} else if let label = label as? UITextView,
								let attributedString = label.attributedText.mutableCopy() as? NSMutableAttributedString {
				attributedString.addAttribute(.foregroundColor,
																			value: foregroundColor.uiColor,
																			range: NSRange(location: 0, length: attributedString.string.count))
				label.attributedText = attributedString
			}
		}

		let contrastRatio = foregroundColor.perceivedBrightness(onBackgroundColor: backgroundColor)
		contrastRatioLabel.text = "Contrast: \(String(format: "%.2f", contrastRatio)) (\(Self.percentFormatter.string(for: contrastRatio / 21)!))"
		aaComplianceLabel.isCompliant = contrastRatio > 4.5
		aaaComplianceLabel.isCompliant = contrastRatio > 7
	}

}
