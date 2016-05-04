//
//  CanvasTextView.swift
//  Canvas
//
//  Created by Sam Soffes on 4/19/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative
import CanvasText

protocol CanvasTextViewFormattingDelegate: class {
	func textViewDidToggleBoldface(textView: CanvasTextView, sender: AnyObject?)
	func textViewDidToggleItalics(textView: CanvasTextView, sender: AnyObject?)
}

final class CanvasTextView: TextView {

	// MARK: - Types

	enum DragAction: String {
		case Increase
		case Decrease
	}

	struct DragContext {
		let block: BlockNode
		let contentView: UIView
		let backgroundView = UIView()
		let rect: CGRect
		let yContentOffset: CGFloat
		var dragAction: DragAction? = nil

		init(block: BlockNode, contentView: UIView, rect: CGRect, yContentOffset: CGFloat) {
			self.block = block
			self.contentView = contentView
			self.rect = rect
			self.yContentOffset = yContentOffset

			contentView.userInteractionEnabled = false
			backgroundView.userInteractionEnabled = false
		}

		func rectForContentView(x x: CGFloat) -> CGRect {
			var rect = contentView.bounds
			rect.origin.x = x
			rect.origin.y += yContentOffset
			return rect
		}

		func rectForContentViewMask() -> CGRect {
			var rect = self.rect
			rect.origin.x = 0
			rect.origin.y -= yContentOffset
			rect.size.width = contentView.bounds.size.width
			return rect
		}

		func rectForBackgroundView() -> CGRect {
			var rect = self.rect
			rect.origin.x = 0
			rect.size.width = contentView.bounds.size.width
			return rect
		}

		func tearDown() {
			backgroundView.removeFromSuperview()
			contentView.removeFromSuperview()
		}
	}

	
	// MARK: - Properties

	weak var textController: TextController?
	weak var formattingDelegate: CanvasTextViewFormattingDelegate?

	let dragGestureRecognizer: UIPanGestureRecognizer
	let dragThreshold: CGFloat = 60
	var dragContext: DragContext?


	// MARK: - Initializers

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		dragGestureRecognizer = UIPanGestureRecognizer()

		super.init(frame: frame, textContainer: textContainer)

//		allowsEditingTextAttributes = true
		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive

		registerGestureRecognizers()
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
