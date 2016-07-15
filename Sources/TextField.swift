//
//  TextField.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

final class TextField: UITextField {

	// MARK: - Properties

	override var placeholder: String? {
		didSet {
			guard let placeholder = placeholder, font = font else { return }
			attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
				NSFontAttributeName: font,
				NSForegroundColorAttributeName: Swatch.darkGray
			])
		}
	}

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = Swatch.extraLightGray

		textColor = Swatch.black
		tintColor = Swatch.brand

		layer.cornerRadius = 4
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
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


	// MARK: - UITextField

	override func textRectForBounds(bounds: CGRect) -> CGRect {
		var rect = bounds

		if rightView != nil {
			rect.size.width -= rect.intersect(rightViewRectForBounds(bounds)).width
		}

		return CGRectInset(rect, 12, 12)
	}

	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		return textRectForBounds(bounds)
	}

	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return textRectForBounds(bounds)
	}

	override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
		var rect = super.rightViewRectForBounds(bounds)
		rect.origin.x -= 6
		return rect
	}
	
	
	// MARK: - Private
	
	@objc private func updateFont() {
		font = TextStyle.body.font()
	}
}
