//
//  CanvasTextView+Gestures.swift
//  Canvas
//
//  Created by Sam Soffes on 5/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

extension CanvasTextView {
	func registerGestureRecognizers() {
		dragGestureRecognizer.addTarget(self, action: #selector(pan))
		dragGestureRecognizer.delegate = self
		addGestureRecognizer(dragGestureRecognizer)
	}

	@objc private func pan(sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .Possible: return
		case .Began: dragBegan()
		case .Changed: dragChanged()
		case .Ended: dragEnded(true)
		case .Cancelled, .Failed: dragEnded(false)
		}
	}

	private func dragBegan() {
		guard let context = dragContext else { return }

		addSubview(context.backgroundView)
		addSubview(context.contentView)
	}

	private func dragChanged() {
		guard var context = dragContext else { return }

		var translation = dragGestureRecognizer.translationInView(self).x

		// Prevent dragging h1s left
		if let heading = context.block as? Heading where heading.level.isMinimum {
			translation = max(0, translation)
		}

		// Prevent dragging lists right at the end
		else if let listItem = context.block as? Listable where listItem.indentation.isMaximum {
			translation = min(0, translation)
		}

		context.contentView.frame = context.rectForContentView(x: translation)


		// Calculate block level
		if translation >= dragThreshold {
			context.dragAction = .Increase
		} else if translation <= -dragThreshold {
			context.dragAction = .Decrease
		} else {
			context.dragAction = nil
		}

		dragContext = context
	}

	private func dragEnded(applyAction: Bool) {
		guard let context = dragContext else { return }

		UIView.animateWithDuration(0.15, delay: 0, options: [], animations: {
			context.contentView.frame = context.rectForContentView(x: 0)
		}, completion: { [weak self] _ in
			context.tearDown()

			if applyAction, let action = self?.dragContext?.dragAction, textController = self?.textController {
				switch action {
				case .Increase: textController.increaseBlockLevel(block: context.block)
				case .Decrease: textController.decreaseBlockLevel(block: context.block)
				}
			}

			self?.dragContext = nil
		})
	}

	private func blockRect(point point: CGPoint) -> CGRect? {
		guard let textRange = characterRangeAtPoint(point) else { return nil }

		let range = NSRange(
			location: offsetFromPosition(beginningOfDocument, toPosition: textRange.start),
			length: 0
		)

		let lineRange = (text as NSString).lineRangeForRange(range)

		guard let start = positionFromPosition(beginningOfDocument, offset: lineRange.location),
			end = positionFromPosition(start, offset: lineRange.length),
			lineTextRange = textRangeFromPosition(start, toPosition: end),
			rects = (selectionRectsForRange(lineTextRange) as? [UITextSelectionRect])?.map({ $0.rect })
		else { return nil }

		return rects.filter { $0.size.width > 0 }.reduce(rects[0]) { CGRectUnion($0, $1) }
	}

	private func blockAt(point point: CGPoint) -> BlockNode? {
		guard let textRange = characterRangeAtPoint(point),
			textController = textController
		else { return nil }

		let location = offsetFromPosition(beginningOfDocument, toPosition: textRange.start)
		return textController.blockAt(presentationLocation: location)
	}
}


extension CanvasTextView: UIGestureRecognizerDelegate {
	override func gestureRecognizerShouldBegin(sender: UIGestureRecognizer) -> Bool {
		// Make sure we don't mess with internal UITextView gesture recognizers.
		guard sender == dragGestureRecognizer else { return super.gestureRecognizerShouldBegin(sender) }

		// If there are multiple characters selected, disable the drag since the text view uses that event to adjust the
		// selection.
		if selectedRange.length > 0 {
			return false
		}

		// Ensure it's a horizontal drag
		let velocity = dragGestureRecognizer.velocityInView(self)
		if abs(velocity.y) > abs(velocity.x) {
			return false
		}

		// Get the block
		let point = dragGestureRecognizer.locationInView(self)
		guard let block = blockAt(point: point) else { return false }

		// Disable dragging in the title
		if block is Title {
			return false
		}

		// Get the rect
		guard let rect = blockRect(point: point) else { return false }

		// Content
		let contentView = snapshotViewAfterScreenUpdates(false)

		// Setup context
		let context = DragContext(
			block: block,
			contentView: contentView,
			rect: rect,
			yContentOffset: contentOffset.y
		)

		// Layout views
		contentView.frame = context.rectForContentView(x: 0)
		context.backgroundView.backgroundColor = backgroundColor
		context.backgroundView.frame = context.rectForBackgroundView()

		// Setup mask
		let mask = CAShapeLayer()
		mask.frame = contentView.layer.bounds
		mask.path = UIBezierPath(rect: context.rectForContentViewMask()).CGPath
		contentView.layer.mask = mask

		dragContext = context

		return true
	}
}
