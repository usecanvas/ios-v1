//
//  GrayButton.swift
//  Canvas
//
//  Created by Sam Soffes on 8/9/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

final class GrayButton: UIButton {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Swatch.lightGray

		layer.cornerRadius = 4

		setTitleColor(Swatch.darkGray, forState: .Normal)
		setTitleColor(Swatch.black, forState: .Highlighted)
		setTitleColor(Swatch.extraLightGray, forState: .Disabled)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func intrinsicContentSize() -> CGSize {
		var size = super.intrinsicContentSize()
		size.height = 32
		size.width += 32 * 2
		return size
	}


	// MARK: - UIControl

	override var enabled: Bool {
		didSet {
			backgroundColor = enabled ? Swatch.lightGray.colorWithAlphaComponent(0.5) : Swatch.lightGray
		}
	}

	override var highlighted: Bool {
		didSet {
			backgroundColor = highlighted ? Swatch.lightGray.colorWithAlphaComponent(0.8) : Swatch.lightGray
		}
	}

	override var selected: Bool {
		didSet {
			backgroundColor = selected ? Swatch.lightGray.colorWithAlphaComponent(0.8) : Swatch.lightGray
		}
	}


	// MARK: - Private

	@objc func updateFont() {
		titleLabel?.font = TextStyle.body.font(weight: .medium)
	}
}