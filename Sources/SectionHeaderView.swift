//
//  SectionHeaderView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

	// MARK: - Properties

	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .boldSystemFontOfSize(17)
		label.textColor = Color.black
		return label
	}()


	// MARK: - Initializers

	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 320, height: 28))
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		autoresizingMask = [.FlexibleWidth]

		addSubview(textLabel)

		NSLayoutConstraint.activateConstraints([
			textLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 16),
			textLabel.trailingAnchor.constraintLessThanOrEqualToAnchor(trailingAnchor, constant: -16),
			textLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: 4),
			textLabel.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -4)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		backgroundColor = tintAdjustmentMode == .Dimmed ? Color.extraLightGray.desaturated : Color.extraLightGray
	}
}
