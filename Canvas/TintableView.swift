//
//  TintableView.swift
//  Canvas
//
//  Created by Sam Soffes on 1/14/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class TintableView: UIView {

	// MARK: - Properties

	var highlighted = false {
		didSet {
			updateTintColor()
		}
	}

	var normalTintColor: UIColor? {
		didSet {
			updateTintColor()
		}
	}

	var highlightedTintColor: UIColor? {
		didSet {
			updateTintColor()
		}
	}

	private var settingTintColor = false


	// MARK: - UIView

	override func tintColorDidChange() {
		super.tintColorDidChange()

		if settingTintColor {
			settingTintColor = false
			return
		}

		normalTintColor = tintColor
	}


	// MARK: - Tinting

	func updateTintColor() {
		settingTintColor = true
		tintColor = highlighted ? highlightedTintColor : normalTintColor
	}
}
