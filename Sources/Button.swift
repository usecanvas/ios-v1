//
//  Button.swift
//  Canvas
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

class Button: UIButton {

	// MARK: - Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clearColor()

		layer.cornerRadius = 4
		layer.borderColor = Swatch.white.CGColor

		titleLabel?.font = Font.sansSerif(weight: .medium)
		setTitleColor(Swatch.white, forState: .Normal)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIView

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		layer.borderWidth = traitCollection.displayScale > 1 ? 1.5 : 1
	}
}
