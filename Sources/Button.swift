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

		layer.cornerRadius = 24
		layer.borderColor = Swatch.brand.CGColor
		layer.borderWidth = 2

		titleLabel?.font = Font.sansSerif(weight: .medium)
		setTitleColor(Swatch.brand, forState: .Normal)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIView
	
	override func intrinsicContentSize() -> CGSize {
		var size = super.intrinsicContentSize()
		size.height = 48
		return size
	}
}
