//
//  PillButton.swift
//  Canvas
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

class PillButton: UIButton {

	// MARK: - Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clearColor()

		layer.cornerRadius = 24
		layer.borderWidth = 2

		setTitleColor(Swatch.brand, forState: .Normal)
		setTitleColor(Swatch.lightBlue, forState: .Highlighted)
		setTitleColor(Swatch.darkGray, forState: .Disabled)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
		updateBorderColor()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - UIView
	
	override func intrinsicContentSize() -> CGSize {
		var size = super.intrinsicContentSize()
		size.height = 48
		size.width += 32 * 2
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
	
	@objc func updateFont() {
		titleLabel?.font = TextStyle.body.font(weight: .medium)
	}
}
