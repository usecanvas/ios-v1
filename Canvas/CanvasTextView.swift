//
//  TextView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CanvasText

class CanvasTextView: InsertionPointTextView {

	// MARK: - Properties

	internal var annotations = [UIView]()
	internal var lineNumber: UInt = 1


	// MARK: - Initializers {

	init(textStorage: NSTextStorage) {
		let layoutManager = NSLayoutManager()
		let container = NSTextContainer()
		layoutManager.addTextContainer(container)
		textStorage.addLayoutManager(layoutManager)

		super.init(frame: .zero, textContainer: container)

		alwaysBounceVertical = true
		keyboardDismissMode = .Interactive

		if let textStorage = textStorage as? CanvasTextStorage {
			textStorage.canvasDelegate = self
		}

		let indent = UISwipeGestureRecognizer(target: self, action: "increaseBlockLevelWithGesture:")
		indent.numberOfTouchesRequired = 1
		indent.direction = .Right
		addGestureRecognizer(indent)

		let outdent = UISwipeGestureRecognizer(target: self, action: "decreaseBlockLevelWithGesture:")
		outdent.numberOfTouchesRequired = 1
		outdent.direction = .Left
		addGestureRecognizer(outdent)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView
	
	override func traitCollectionDidChange(previousTraitOrganization: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitOrganization)

		guard let textStorage = textStorage as? CanvasTextStorage else { return }
		textStorage.horizontalSizeClass = traitCollection.horizontalSizeClass
		textStorage.reprocess()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.updateAnnotations()
		}
	}

	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		// I can't believe I have to do this… *sigh*
		for view in subviews {
			if view.userInteractionEnabled && view.frame.contains(point) {
				return view
			}
		}

		return super.hitTest(point, withEvent: event)
	}


	// MARK: - Actions

	@objc private func toggleCheckbox(sender: CheckboxView?) {
		guard let node = sender?.checklist, textStorage = textStorage as? CanvasTextStorage else { return }

		let string = node.completion.opposite.string
		textStorage.replaceBackingCharactersInRange(node.completedRange, withString: string)
	}


	// MARK: - Internal

	internal func nodeAtPoint(point: CGPoint) -> Node? {
		guard let textRange = characterRangeAtPoint(point),
			textStorage = textStorage as? CanvasTextStorage
			else { return nil }

		let range = NSRange(
			location: offsetFromPosition(beginningOfDocument, toPosition: textRange.start),
			length: offsetFromPosition(textRange.start, toPosition: textRange.end)
		)

		return textStorage.firstNodeInDisplayRange(range)
	}

	internal func firstRectForRange(range: NSRange) -> CGRect? {
		guard let start = positionFromPosition(beginningOfDocument, offset: range.location),
			end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		return firstRectForRange(textRange)
	}

	internal func firstRectForNode(node: Node) -> CGRect? {
		guard let textStorage = textStorage as? CanvasTextStorage else { return nil }
		let range = textStorage.backingRangeToDisplayRange(node.contentRange)
		return firstRectForRange(range)
	}
}


extension CanvasTextView: CanvasTextStorageDelegate {
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage) {
		updateAnnotations()
		setNeedsDisplay()
	}

	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment? {
		guard let node = node as? Image, scale = window?.screen.scale else { return nil }
		let attachment = NSTextAttachment()

		// Not sure why it’s off by 10 here
		let width = textContainer.size.width - 10

		var size = node.size ?? CGSize(width: floor(width), height: 300)
		let image = ImagesController.sharedController.fetchImage(node: node, size: size, scale: scale) { [weak self] node, image in
			guard let image = image,
				textStorage = self?.textStorage as? CanvasTextStorage
			else { return }

			let range = textStorage.backingRangeToDisplayRange(node.contentRange)
			var attributes = textStorage.attributesAtIndex(range.location, effectiveRange: nil)

			let size = image.size
			let updatedAttachment = NSTextAttachment()
			updatedAttachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * size.height / size.width)
			updatedAttachment.image = image
			attributes[NSAttachmentAttributeName] = updatedAttachment

			textStorage.setAttributes(attributes, range: range)
			textStorage.edited([.EditedAttributes], range: range, changeInLength: 0)
		}

		attachment.image = image

		size = image?.size ?? CGSize(width: floor(width), height: 300)
		attachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * size.height / size.width).ceil

		return attachment
	}
}
