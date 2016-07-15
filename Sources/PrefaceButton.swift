//
//  PrefaceButton.swift
//  Canvas
//
//  Created by Sam Soffes on 7/13/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

class PrefaceButton: PillButton {
	
	// MARK: - Initializers
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		titleLabel?.numberOfLines = 0
		titleLabel?.textAlignment = .Center
		layer.borderWidth = 0
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - Preface
	
	func set(preface preface: String, title: String) {
		// Use non-breaking spaces for the title
		let title = title.stringByReplacingOccurrencesOfString(" ", withString: "\u{00A0}")
		
		// TODO: Localize
		let string = "\(preface) \(title)"
		let emphasizedRange = NSRange(
			location: (preface as NSString).length + 1,
			length: (title as NSString).length
		)
		
		let normalText = NSMutableAttributedString(string: string, attributes: [
			NSFontAttributeName: Font.sansSerif(size: .body),
			NSForegroundColorAttributeName: Swatch.darkGray
		])
		
		normalText.setAttributes([
			NSFontAttributeName: Font.sansSerif(size: .body, weight: .medium),
			NSForegroundColorAttributeName: Swatch.brand
		], range: emphasizedRange)
		
		setAttributedTitle(normalText, forState: .Normal)
		
		let highlightedText = NSMutableAttributedString(string: string, attributes: [
			NSFontAttributeName: Font.sansSerif(size: .body),
			
			// TODO: Use a named color for this
			NSForegroundColorAttributeName: Swatch.darkGray.colorWithAlphaComponent(0.6)
		])
		
		highlightedText.setAttributes([
			NSFontAttributeName: Font.sansSerif(size: .body, weight: .medium),
			NSForegroundColorAttributeName: Swatch.lightBlue
		], range: emphasizedRange)
		
		setAttributedTitle(highlightedText, forState: .Highlighted)
		
		let disabledText = NSAttributedString(string: string, attributes: [
			NSFontAttributeName: Font.sansSerif(size: .body),
			NSForegroundColorAttributeName: Swatch.darkGray
		])
		setAttributedTitle(disabledText, forState: .Disabled)
	}
}
