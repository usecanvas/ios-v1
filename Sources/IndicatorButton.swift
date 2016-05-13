//
//  IndicatorButton.swift
//  Canvas
//
//  Created by Sam Soffes on 5/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class IndicatorButton: Button {

	// MARK: - Properties

	var loading = false {
		didSet {
			titleLabel?.alpha = loading ? 0 : 1

			if loading {
				activityIndicator.startAnimating()
			} else {
				activityIndicator.stopAnimating()
			}
		}
	}

	let activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
		indicator.translatesAutoresizingMaskIntoConstraints = false
		indicator.userInteractionEnabled = false
		indicator.hidesWhenStopped = true
		return indicator
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(activityIndicator)

		NSLayoutConstraint.activateConstraints([
			activityIndicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
			activityIndicator.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
			activityIndicator.topAnchor.constraintLessThanOrEqualToAnchor(topAnchor),
			activityIndicator.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomAnchor)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		activityIndicator.color = tintColor
	}
}
