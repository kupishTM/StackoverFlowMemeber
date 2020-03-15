//
//  BadgeView.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import UIKit

final class BadgeView: UIView {
	private var borderColor: UIColor {
		switch style {
		case .gold:
			return Constants.goldBorderColor
		case .silver:
			return Constants.silverBorderColor
		case .bronze:
			return Constants.bronzeBorderColor
		case .noStyle:
			return .white
		}
	}

	private var fillColor: UIColor {
		switch style {
		case .gold:
			return Constants.goldFillColor
		case .silver:
			return Constants.silverFillColor
		case .bronze:
			return Constants.bronzeFillColor
		case .noStyle:
			return .white
		}
	}

	private let countLabel: UILabel = {
		let label = UILabel(frame: .zero)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var style: Style = .noStyle

	func apply(with count: String, style: Style) {
		self.countLabel.attributedText = generateAttributedText(count: count, style: style)
		if style != self.style {
			self.style = style
			applyStyle(style)
		}
	}

	private override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	func commonInit() {
		self.addSubview(countLabel)
		NSLayoutConstraint.activate([
			countLabel.topAnchor.constraint(equalTo: self.topAnchor),
			countLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			countLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
			countLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
		])
	}

	func applyStyle(_ style: Style) {
		layer.borderWidth = 1
		layer.borderColor = borderColor.cgColor
		layer.cornerRadius = 5
		backgroundColor = fillColor
	}

	func generateAttributedText(count: String, style: Style) -> NSAttributedString {
		let textColor: UIColor
		switch style {
		case .gold:
			textColor = Constants.goldColor
		case .silver:
			textColor = Constants.silverColor
		case .bronze:
			textColor = Constants.bronzeColor
		case .noStyle:
			textColor = .black
		}

		let mainfont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
		let bullet = NSMutableAttributedString(string: "•",
													 attributes: [NSAttributedString.Key.font: mainfont,
																  NSAttributedString.Key.foregroundColor: textColor])
		let number = NSAttributedString(string: " \(count)", attributes: [NSAttributedString.Key.font: mainfont,
																		   NSAttributedString.Key.foregroundColor: UIColor.black])
		bullet.append(number)
		return bullet
	}
}

// MARK: - Constants & Style
extension BadgeView {
	enum Constants {
		static let font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.bold)

		static let goldColor = UIColor(red: 247/255, green: 206/255, blue: 70/255, alpha: 1.0)
		static let silverColor = UIColor(red: 181/255, green: 184/255, blue: 188/255, alpha: 1.0)
		static let bronzeColor = UIColor(red: 203/255, green: 167/255, blue: 137/255, alpha: 1.0)

		static let goldBorderColor = UIColor(red: 232/255, green: 184/255, blue: 63/255, alpha: 1.0)
		static let silverBorderColor = UIColor(red: 154/255, green: 156/255, blue: 159/255, alpha: 1.0)
		static let bronzeBorderColor = UIColor(red: 165/255, green: 131/255, blue: 100/255, alpha: 1.0)

		static let goldFillColor = UIColor(red: 253/255, green: 244/255, blue: 213/255, alpha: 1.0)
		static let silverFillColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
		static let bronzeFillColor = UIColor(red: 241/255, green: 233/255, blue: 226/255, alpha: 1.0)
	}

	enum Style {
		case gold
		case silver
		case bronze
		case noStyle
	}
}
