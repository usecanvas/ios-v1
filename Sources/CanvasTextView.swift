//
//  CanvasTextView.swift
//  Canvas
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

protocol CanvasTextViewFormattingDelegate: class {
	func textViewDidToggleBoldface(textView: CanvasTextView, sender: AnyObject?)
	func textViewDidToggleItalics(textView: CanvasTextView, sender: AnyObject?)
}

final class CanvasTextView: TextView {

	// MARK: - Properties

	weak var formattingDelegate: CanvasTextViewFormattingDelegate?


	// MARK: - Initializers

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
//		allowsEditingTextAttributes = true
		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder
	
	override func toggleBoldface(sender: AnyObject?) {
		formattingDelegate?.textViewDidToggleBoldface(self, sender: sender)
	}

	override func toggleItalics(sender: AnyObject?) {
		formattingDelegate?.textViewDidToggleItalics(self, sender: sender)
	}

	override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		// Disable underline
		if action == #selector(toggleUnderline) {
			return false
		}

		return super.canPerformAction(action, withSender: sender)
	}
}


extension CanvasTextView: TextControllerAnnotationDelegate {
	func textController(textController: TextController, willAddAnnotation annotation: Annotation) {
		managedSubviews.insert(annotation.view)
		insertSubview(annotation.view, atIndex: 0)
	}

	func textController(textController: TextController, willRemoveAnnotation annotation: Annotation) {
		managedSubviews.remove(annotation.view)
	}

	func textController(textController: TextController, firstRectForRange range: NSRange) -> CGRect? {
		guard let start = positionFromPosition(beginningOfDocument, offset: range.location),
			end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		var rect = firstRectForRange(textRange)
		rect.origin.y -= textContainerInset.top
		rect.origin.x -= textContainerInset.left
		return rect
	}
}
