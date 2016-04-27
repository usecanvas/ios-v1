//
//  TextView.swift
//  Canvas
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class TextView: UITextView {

	// MARK: - UIView

	// Allow subviews to receive user input
	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		for view in subviews {
			if view.userInteractionEnabled && view.frame.contains(point) {
				return view
			}
		}

		return super.hitTest(point, withEvent: event)
	}
	

	// MARK: - UITextInput

	// Only display the caret in the used rect (if available).
	override func caretRectForPosition(position: UITextPosition) -> CGRect {
		var rect = super.caretRectForPosition(position)
		
		if let layoutManager = textContainer.layoutManager {
			layoutManager.ensureLayoutForTextContainer(textContainer)
			
			let characterIndex = offsetFromPosition(beginningOfDocument, toPosition: position)
			if characterIndex == textStorage.length {
				return rect
			}
			
			let glyphIndex = layoutManager.glyphIndexForCharacterAtIndex(characterIndex)
			
			if UInt(glyphIndex) == UInt.max - 1 {
				return rect
			}
			
			let height = layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: nil).size.height
			
			if height > 0 {
				rect.size.height = height
			}
		}
		
		return rect
	}
}
