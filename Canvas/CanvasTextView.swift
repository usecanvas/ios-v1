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

	private var annotations = [UIView]()
	private var lineNumber: UInt = 1


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

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - UIView
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

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


	// MARK: - Gestures

	func increaseBlockLevelWithGesture(sender: UISwipeGestureRecognizer?) {
		guard let sender = sender,
			textStorage = textStorage as? CanvasTextStorage,
			node = nodeAtPoint(sender.locationInView(self))
		else { return }

		// Convert paragraph to unordered list
		if node is Paragraph {
			let string = Checklist.nativeRepresentation()
			var range = node.contentRange
			range.length = 0
			textStorage.replaceBackingCharactersInRange(range, withString: string)
			return
		}

		// Convert checklist to unordered list
		if let node = node as? Checklist {
			let string = UnorderedList.nativeRepresentation()
			textStorage.replaceBackingCharactersInRange(node.delimiterRange.union(node.prefixRange), withString: string)
			return
		}

		// Lists
		if let node = node as? Listable {
			// Increment indentation
			let newIndentation = node.indentation.successor

			// Already at its maximum indentation
			if newIndentation == node.indentation {
				return
			}

			let string = newIndentation.string
			textStorage.replaceBackingCharactersInRange(node.indentationRange, withString: string)
			return
		}

		// Decrease headings
		if let node = node as? Heading {
			// Convert to Paragraph
			if node.level == .Three {
				textStorage.replaceBackingCharactersInRange(node.prefixRange, withString: "")
				return
			}

			let string = Heading.nativeRepresentation(level: node.level.successor)
			textStorage.replaceBackingCharactersInRange(node.prefixRange, withString: string)
			return
		}
	}

	func decreaseBlockLevelWithGesture(sender: UISwipeGestureRecognizer?) {
		guard let sender = sender,
			textStorage = textStorage as? CanvasTextStorage,
			node = nodeAtPoint(sender.locationInView(self))
		else { return }

		// Lists
		if let node = node as? Listable {
			// Convert checklist to paragraph
			if let node = node as? Checklist {
				textStorage.replaceBackingCharactersInRange(node.delimiterRange.union(node.prefixRange), withString: "")
				return
			}

			// Convert unordered list to checklist
			let newIndentation = node.indentation.predecessor
			if newIndentation == node.indentation {
				let string = Checklist.nativeRepresentation()
				textStorage.replaceBackingCharactersInRange(node.delimiterRange.union(node.prefixRange), withString: string)
				return
			}

			// Decrement indentation
			let string = newIndentation.string
			textStorage.replaceBackingCharactersInRange(node.indentationRange, withString: string)
			return
		}

		// Convert Paragraph to Heading
		if node is Paragraph {
			let string = Heading.nativeRepresentation(level: .Three)
			var range = node.contentRange
			range.length = 0
			textStorage.replaceBackingCharactersInRange(range, withString: string)
			return
		}

		// Increase Heading level
		if let node = node as? Heading where node.level != .One {
			let string = Heading.nativeRepresentation(level: node.level.predecessor)
			textStorage.replaceBackingCharactersInRange(node.prefixRange, withString: string)
			return
		}
	}


	// MARK: - Annotations

	func updateAnnotations() {
		annotations.forEach { $0.removeFromSuperview() }
		annotations.removeAll()

		lineNumber = 1

		// Add annotations
		let needsFirstResponder = !isFirstResponder()
		if needsFirstResponder {
			becomeFirstResponder()
		}

		guard let textStorage = textStorage as? CanvasTextStorage else { return }

		// Make sure the layout is ready since we calculate annotations based off of that
		layoutManager.ensureLayoutForTextContainer(textContainer)

		var orderedIndentationCounts = [Indentation: UInt]()

		let count = textStorage.nodes.count
		for (i, node) in textStorage.nodes.enumerate() {
			let next: Node?
			if i < count - 1 {
				next = textStorage.nodes[i + 1]
			} else {
				next = nil
			}

			let previous: Node?
			if i > 0 {
				previous = textStorage.nodes[i - 1]
			} else {
				previous = nil
			}

			if node is Listable {
				if let node = node as? OrderedList {
					let value = orderedIndentationCounts[node.indentation] ?? 0
					orderedIndentationCounts[node.indentation] = value + 1
				}
			} else {
				orderedIndentationCounts.removeAll()
			}

			if node.hasAnnotation, let annotation = annotationForNode(node, nextSibling: next, previousSibling: previous, orderedIndentationCounts: orderedIndentationCounts) {
				addAnnotation(annotation)
			}
		}

		if needsFirstResponder {
			resignFirstResponder()
		}
	}


	// MARK: - Actions

	@objc private func toggleCheckbox(sender: CheckboxView?) {
		guard let node = sender?.checklist, textStorage = textStorage as? CanvasTextStorage else { return }

		let string = node.completion.opposite.string
		textStorage.replaceBackingCharactersInRange(node.completedRange, withString: string)
	}


	// MARK: - Private

	@objc private func keyboardWillChangeFrame(notification: NSNotification?) {
		guard let notification = notification,
			value = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
		else { return }

		let frame = convertRect(value.CGRectValue(), fromView: nil)
		contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
		scrollIndicatorInsets = contentInset
	}

	private func nodeAtPoint(point: CGPoint) -> Node? {
		guard let textRange = characterRangeAtPoint(point),
			textStorage = textStorage as? CanvasTextStorage
		else { return nil }

		let range = NSRange(
			location: offsetFromPosition(beginningOfDocument, toPosition: textRange.start),
			length: offsetFromPosition(textRange.start, toPosition: textRange.end)
		)

		var node: Node?
		for n in textStorage.nodes {
			let content = textStorage.backingRangeToDisplayRange(n.contentRange)
			if content.intersection(range) > 0 {
				node = n
				break
			}
		}

		return node
	}

	private func addAnnotation(annotation: UIView) {
		annotations.append(annotation)
		insertSubview(annotation, atIndex: 0)
	}

	private func annotationForNode(node: Node, nextSibling: Node? = nil, previousSibling: Node? = nil, orderedIndentationCounts: [Indentation: UInt]) -> UIView? {
		guard let textStorage = textStorage as? CanvasTextStorage else { return nil }

		guard var rect = firstRectForNode(node) else { return nil }

		let theme = textStorage.theme
		let font = theme.fontOfSize(theme.fontSize, style: [])

		// Unordered List
		if let node = node as? UnorderedList {
			let view = BulletView(frame: .zero, unorderedList: node)
			let size = view.intrinsicContentSize()

			rect.origin.x -= theme.listIndentation - (size.width / 2)
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect

			return view
		}

		// Ordered list
		if let node = node as? OrderedList {
			let value = orderedIndentationCounts[node.indentation] ?? 1
			let view = NumberView(frame: .zero, theme: theme, value: value)
			view.sizeToFit()

			let size = view.bounds.size
			let baseline = rect.maxY + font.descender
			let numberBaseline = size.height + view.font!.descender
			let scale = window!.screen.scale

			rect.origin.x -= size.width + 4
			rect.origin.y = ceil((baseline - numberBaseline) * scale) / scale
			rect.size = size
			view.frame = rect

			return view
		}

		// Checklist
		if let node = node as? Checklist {
			let view = CheckboxView(frame: .zero, checklist: node)
			view.addTarget(self, action: "toggleCheckbox:", forControlEvents: .TouchUpInside)
			let size = view.intrinsicContentSize()
			rect.origin.x -= theme.listIndentation
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect
			return view
		}

		// Blockquote
		if node is Blockquote {
			let view = BlockquoteBorderView(frame: .zero)
			rect.origin.x -= theme.listIndentation
			rect.size.width = 4

			// Extend vertically if the next node is also a blockquote
			if let next = nextSibling as? Blockquote, let nextRect = firstRectForRange(textStorage.backingRangeToDisplayRange(next.contentRange)) {
				rect.size.height = nextRect.origin.y - rect.origin.y
			}

			view.frame = rect

			return view
		}

		// Code block
		if node is CodeBlock {
			if traitCollection.horizontalSizeClass == .Compact {
				rect.origin.x = 0
				rect.size.width = bounds.width
			} else {
				rect.origin.x -= 48
				rect.size.width = textContainer.size.width
			}

			var position = CodeBlockBackgroundView.Position()
			let originalTop = rect.origin.y

			// Find the bottom of line (to handle wrapping)
			var range = textStorage.backingRangeToDisplayRange(node.contentRange)
			if range.length > 1 {
				range.location += range.length - 1
				range.length = 1
			}

			if let lastRect = firstRectForRange(range) where lastRect.origin.y > originalTop {
				rect.size.height += lastRect.origin.y - originalTop
			}

			// Top
			if !(previousSibling is CodeBlock) {
				position = position.union([.Top])
				rect.origin.y -= theme.paragraphSpacing / 4
				rect.size.height += theme.paragraphSpacing / 4
			}

			// Bottom
			if !(nextSibling is CodeBlock) {
				position = position.union([.Bottom])
				rect.size.height += theme.paragraphSpacing / 2
			}

			let view = CodeBlockBackgroundView(frame: rect.floor, theme: textStorage.theme, lineNumber: lineNumber, position: position)

			if position.contains(.Bottom) {
				lineNumber = 1
			} else {
				lineNumber += 1
			}

			return view
		}

		return nil
	}

	private func firstRectForRange(range: NSRange) -> CGRect? {
		guard let start = positionFromPosition(beginningOfDocument, offset: range.location),
			end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		return firstRectForRange(textRange)
	}

	private func firstRectForNode(node: Node) -> CGRect? {
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
		guard let image = node as? Image, scale = window?.screen.scale else { return nil }
		let attachment = NSTextAttachment()

		// Not sure why it’s off by 10 here
		let width = textContainer.size.width - 10
		attachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * image.size.height / image.size.width)

		let size = attachment.bounds.ceil.size
		attachment.image = ImagesController.sharedController.fetchImage(node: image, size: size, scale: scale) { [weak self] node, image in
			guard let image = image,
				textStorage = self?.textStorage as? CanvasTextStorage
			else { return }

			let range = textStorage.backingRangeToDisplayRange(node.contentRange)
			var attributes = textStorage.attributesAtIndex(range.location, effectiveRange: nil)

			guard let attachment = attributes[NSAttachmentAttributeName] as? NSTextAttachment else { return }

			let updatedAttachment = NSTextAttachment()
			updatedAttachment.bounds = attachment.bounds
			updatedAttachment.image = image
			attributes[NSAttachmentAttributeName] = updatedAttachment

			textStorage.setAttributes(attributes, range: range)
			textStorage.edited([.EditedAttributes], range: range, changeInLength: 0)
		}

		return attachment
	}
}
