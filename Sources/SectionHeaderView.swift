//
//  SectionHeaderView.swift
//  Canvas
//
//  Created by Sam Soffes on 6/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

class SectionHeaderView: UIView {

	// MARK: - Properties

	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Swatch.black
		return label
	}()


	// MARK: - Initializers

	convenience init(title: String) {
		self.init(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
		textLabel.text = title
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
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()
		backgroundColor = tintAdjustmentMode == .Dimmed ? Swatch.extraLightGray.desaturated : Swatch.extraLightGray
	}
	
	
	// MARK: - Fonts
	
	func updateFont() {
		textLabel.font = TextStyle.callout.font(weight: .medium)
	}
}
