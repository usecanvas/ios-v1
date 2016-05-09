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

		context.translate(x: translation)

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
			context.translate(x: 0)
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

	private func blockAt(point point: CGPoint) -> BlockNode? {
		guard let textController = textController else { return nil }
		let location = layoutManager.characterIndexForPoint(point, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		return textController.currentDocument.blockAt(presentationLocation: location)
	}
}


extension CanvasTextView: UIGestureRecognizerDelegate {
	override func gestureRecognizerShouldBegin(sender: UIGestureRecognizer) -> Bool {
		// Make sure we don't mess with internal UITextView gesture recognizers.
		guard sender == dragGestureRecognizer, let textController = textController else { return super.gestureRecognizerShouldBegin(sender) }

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

		// Disable dragging if unsupported
		if !(block is Paragraph) && !(block is Heading) && !(block is Listable) {
			return false
		}

		// Get the block rect
		let characterRange = textController.currentDocument.presentationRange(backingRange: block.visibleRange)
		let glyphRange = layoutManager.glyphRangeForCharacterRange(characterRange, actualCharacterRange: nil)
		var rect = layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
		rect.origin.x += textContainerInset.left
		rect.origin.y += textContainerInset.top

		// Content
		let contentView = snapshotViewAfterScreenUpdates(false)

		// Background
		let background = UIView()
		background.backgroundColor = backgroundColor

		// Setup context
		let context = DragContext(
			block: block,
			contentView: contentView,
			backgroundView: background,
			rect: rect,
			yContentOffset: contentOffset.y
		)
		
		dragContext = context
		
		return true
	}
}
