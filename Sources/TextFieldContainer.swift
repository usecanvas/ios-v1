//
//  TextFieldContainer.swift
//  Canvas
//
//  Created by Sam Soffes on 5/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class TextFieldContainer: UIView {

	// MARK: - Properties

	let visualEffectView: UIVisualEffectView
	let textField: UITextField


	// MARK: - Initializers

	init(visualEffectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)), textField: UITextField = UITextField()) {
		self.visualEffectView = visualEffectView
		self.textField = textField

		super.init(frame: .zero)

		visualEffectView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(visualEffectView)

		textField.translatesAutoresizingMaskIntoConstraints = false
		visualEffectView.contentView.addSubview(textField)

		NSLayoutConstraint.activateConstraints([
			textField.topAnchor.constraintEqualToAnchor(topAnchor),
			textField.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
			textField.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			textField.trailingAnchor.constraintEqualToAnchor(trailingAnchor),

			visualEffectView.topAnchor.constraintEqualToAnchor(textField.topAnchor),
			visualEffectView.bottomAnchor.constraintEqualToAnchor(textField.bottomAnchor),
			visualEffectView.leadingAnchor.constraintEqualToAnchor(textField.leadingAnchor),
			visualEffectView.trailingAnchor.constraintEqualToAnchor(textField.trailingAnchor),
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class func layerClass() -> AnyClass {
		return CATransformLayer.self
	}
}
