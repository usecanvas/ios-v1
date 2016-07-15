//
//  BannerView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

final class BannerView: UIView {

	// MARK: - Types

	enum Style {
		case success
		case info
		case failure

		var foregroundColor: UIColor {
			return Swatch.white
		}

		var backgroundColor: UIColor {
			switch self {
			case .success: return Swatch.green
			case .info: return Swatch.darkGray
			case .failure: return Swatch.destructive
			}
		}
	}


	// MARK: - Properties

	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .Center
		return label
	}()


	// MARK: - Initializers

	init(style: Style) {
		super.init(frame: .zero)

		backgroundColor = style.backgroundColor

		textLabel.textColor = style.foregroundColor
		addSubview(textLabel)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()

		NSLayoutConstraint.activateConstraints([
			textLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
			textLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
			textLabel.leadingAnchor.constraintGreaterThanOrEqualToAnchor(leadingAnchor, constant: 16),
			textLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(trailingAnchor, constant: -16),
			textLabel.topAnchor.constraintGreaterThanOrEqualToAnchor(topAnchor, constant: 12),
			textLabel.bottomAnchor.constraintGreaterThanOrEqualToAnchor(bottomAnchor, constant: -12),
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	@objc private func updateFont() {
		textLabel.font = TextStyle.callout.font(weight: .medium)
	}
}
