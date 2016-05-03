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

	// MARK: - Properties

	weak var textController: TextController?
	weak var formattingDelegate: CanvasTextViewFormattingDelegate?

	private let gestureRecognizer: UIPanGestureRecognizer
	private var draggingView: UIView?
	private var draggingBackgroundView: UIView?


	// MARK: - Initializers

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		gestureRecognizer = UIPanGestureRecognizer()

		super.init(frame: frame, textContainer: textContainer)

//		allowsEditingTextAttributes = true
		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive

		gestureRecognizer.addTarget(self, action: #selector(pan))
		gestureRecognizer.delegate = self
		addGestureRecognizer(gestureRecognizer)
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


	// MARK: - Private

	private func blockAt(point point: CGPoint) -> BlockNode? {
		guard let textRange = characterRangeAtPoint(point),
			textController = textController
		else { return nil }

		let location = offsetFromPosition(beginningOfDocument, toPosition: textRange.start)
		return textController.blockAt(presentationLocation: location)
	}

	@objc private func pan(sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .Began:
			let point = sender.locationInView(self)
			guard let textRange = characterRangeAtPoint(point) else { return }

			let range = NSRange(
				location: offsetFromPosition(beginningOfDocument, toPosition: textRange.start),
				length: 0
			)

			let lineRange = (text as NSString).lineRangeForRange(range)

			guard let start = positionFromPosition(beginningOfDocument, offset: lineRange.location),
				end = positionFromPosition(start, offset: lineRange.length),
				lineTextRange = textRangeFromPosition(start, toPosition: end),
				rects = (selectionRectsForRange(lineTextRange) as? [UITextSelectionRect])?.map({ $0.rect })
			else { return }

			var rect = rects.filter { $0.size.width > 0 }.reduce(rects[0]) { CGRectUnion($0, $1) }
			rect.origin.x = 0
			rect.origin.y -= contentOffset.y
			rect.size.width = bounds.size.width

			let maskRect = rect

			rect.origin.y += contentOffset.y

			let background = UIView(frame: rect)
			background.backgroundColor = .whiteColor()
			draggingBackgroundView = background
			addSubview(background)

			let view = snapshotViewAfterScreenUpdates(false)
			let mask = CAShapeLayer()
			mask.frame = view.layer.bounds
			mask.path = UIBezierPath(rect: maskRect).CGPath

			rect = view.frame
			rect.origin.y += contentOffset.y
			view.frame = rect

			view.layer.mask = mask
			draggingView = view
			addSubview(view)
		case .Changed:
			guard let view = draggingView else { return }
			var frame = view.frame
			frame.origin.x = sender.translationInView(self).x
			view.frame = frame
		case .Ended, .Cancelled:
			let cleanUp = { [weak self] in
				self?.draggingBackgroundView?.removeFromSuperview()
				self?.draggingBackgroundView = nil
				self?.draggingView?.removeFromSuperview()
				self?.draggingView = nil
			}

			guard let draggingView = draggingView else {
				cleanUp()
				return
			}

			UIView.animateWithDuration(0.2, delay: 0, options: [], animations: {
				var frame = draggingView.frame
				frame.origin.x = 0
				draggingView.frame = frame
			}, completion: { _ in cleanUp() })
		default: return
		}
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


extension CanvasTextView: UIGestureRecognizerDelegate {
	override func gestureRecognizerShouldBegin(sender: UIGestureRecognizer) -> Bool {
		// Make sure we don't mess with internal UITextView gesture recognizers.
		guard sender == gestureRecognizer else { return true }

		// Ensure it's a horizontal drag
		let velocity = gestureRecognizer.velocityInView(self)
		if abs(velocity.y) > abs(velocity.x) {
			return false
		}

		// Disable dragging in the title
		let point = gestureRecognizer.locationInView(self)
		if let block = blockAt(point: point) where block is Title {
			return false
		}

		// If there are multiple characters selected, disable the drag since the text view uses that event to adjust the
		// selection.
		return selectedRange.length == 0
	}
}
