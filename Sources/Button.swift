//
//  Button.swift
//  Canvas
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

class Button: UIButton {

	// MARK: - Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clearColor()

		layer.cornerRadius = 24
		layer.borderColor = Swatch.brand.CGColor
		layer.borderWidth = 2

		titleLabel?.font = TextStyle.Body.font(traits: .TraitBold)
		setTitleColor(Swatch.brand, forState: .Normal)
		setTitleColor(Swatch.lightBlue, forState: .Highlighted)
		setTitleColor(Swatch.gray, forState: .Disabled)
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


	// MARK: - UIControl

	override var enabled: Bool {
		didSet {
			updateBorderColor()
		}
	}

	override var highlighted: Bool {
		didSet {
			updateBorderColor()
		}
	}

	override var selected: Bool {
		didSet {
			updateBorderColor()
		}
	}


	// MARK: - Private

	private func updateBorderColor() {
		layer.borderColor = titleColorForState(state)?.CGColor
	}
}
