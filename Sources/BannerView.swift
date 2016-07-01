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

	// MARK: - Properties

	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Swatch.white
		label.numberOfLines = 0
		return label
	}()


	// MARK: - Initializers

	init() {
		super.init(frame: .zero)
		backgroundColor = Swatch.green

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
