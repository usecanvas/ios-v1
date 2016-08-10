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

	// MARK: - Properties

	var managedSubviews = Set<UIView>()


	// MARK: - UIView

	// Allow subviews to receive user input
	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		for view in managedSubviews {
			if view.superview == self && view.userInteractionEnabled && view.frame.contains(point) {
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
			
			let usedRect = layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: nil)

			if usedRect.height > 0 {
				rect.origin.y = usedRect.minY + textContainerInset.top
				rect.size.height = usedRect.height
			}
		}
		
		return rect
	}

	// Omit empty width rect when drawing selection rects.
	override func selectionRectsForRange(range: UITextRange) -> [AnyObject] {
		let selectionRects = super.selectionRectsForRange(range)
		return selectionRects.filter({ selection in
			guard let selection = selection as? UITextSelectionRect else { return false }
			return selection.rect.size.width > 0
		})
	}

	func rectsForRange(range: NSRange) -> [CGRect] {
		// Become first responder if we aren't already. The text view has to be first responder for any of the position
		// or text range APIs to work. Annoying :(
		let wasFirstResponder = isFirstResponder()
		if !wasFirstResponder {
			becomeFirstResponder()
		}

		// Get starting position
		guard let start = positionFromPosition(beginningOfDocument, offset: range.location) else {
			if !wasFirstResponder {
				resignFirstResponder()
			}
			return []
		}

		// Empty selection
		if range.length == 0 {
			if !wasFirstResponder {
				resignFirstResponder()
			}
			return [caretRectForPosition(start)]
		}

		// Selection
		guard let end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end),
			selectionRects = (super.selectionRectsForRange(textRange) as? [UITextSelectionRect])?.map({ $0.rect }),
			firstRect = selectionRects.first
		else {
			// Use extra line if there aren't any rects
			var rect = layoutManager.extraLineFragmentUsedRect
			rect.origin.x += textContainerInset.left
			rect.origin.y += textContainerInset.top

			if !wasFirstResponder {
				resignFirstResponder()
			}

			return [rect]
		}

		if !wasFirstResponder {
			resignFirstResponder()
		}

		let filtered = selectionRects.filter { $0.width > 0 }

		if filtered.isEmpty {
			return [firstRect]
		}

		return filtered
	}
}
