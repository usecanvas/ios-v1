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

class TextView: UITextView {

	// MARK: - Properties

	private var annotations = [UIView]()
	private var imageAttachments = [Image: NSTextAttachment]()
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
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class func layerClass() -> AnyClass {
		return TextViewLayer.self
	}
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard let textStorage = textStorage as? CanvasTextStorage else { return }
		textStorage.horizontalSizeClass = traitCollection.horizontalSizeClass
		textStorage.reprocess()

		dispatch_async(dispatch_get_main_queue()) { [weak self] in
			self?.updateAnnotations()
		}
	}


	// MARK: - Annotations

	func updateAnnotations() {
		annotations.forEach { $0.removeFromSuperview() }
		annotations.removeAll()
		imageAttachments.removeAll()

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


	// MARK: - Private

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

			let position: CodeBlockBackgroundView.Position

			if !(previousSibling is CodeBlock) {
				position = .Top
				rect.origin.y -= theme.paragraphSpacing / 4
				rect.size.height += theme.paragraphSpacing / 4
			} else if let next = nextSibling as? CodeBlock {
				position = .Middle

				if let nextRect = firstRectForRange(textStorage.backingRangeToDisplayRange(next.contentRange)) {
					rect.size.height = ceil(nextRect.origin.y - rect.origin.y)
				}
			} else {
				position = .Bottom
				rect.size.height += theme.paragraphSpacing / 2
			}

			let view = CodeBlockBackgroundView(frame: rect.floor, theme: textStorage.theme, lineNumber: lineNumber, position: position)
			lineNumber += 1
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


extension TextView: CanvasTextStorageDelegate {
	func textStorageDidUpdateNodes(textStorage: CanvasTextStorage) {
		updateAnnotations()
		setNeedsDisplay()
	}

	func textStorage(textStorage: CanvasTextStorage, attachmentForAttachable node: Attachable) -> NSTextAttachment? {
		guard let image = node as? Image else { return nil }
		let attachment = NSTextAttachment()

		// Not sure why it’s off by 10 here
		let width = textContainer.size.width - 10
		attachment.bounds = CGRect(x: 0, y: 0, width: width, height: width * image.size.height / image.size.width)

		imageAttachments[image] = attachment

		let size = attachment.bounds.ceil.size
		attachment.image = ImagesController.sharedController.fetchImage(node: image, size: size) { [weak self] node, image in
			if let image = image, attachment = self?.imageAttachments[node], textStorage = self?.textStorage as? CanvasTextStorage {
				attachment.image = image

				let range = textStorage.backingRangeToDisplayRange(node.contentRange)
				textStorage.edited([.EditedAttributes], range: range, changeInLength: 0)
			}
		}

		imageAttachments[image] = attachment

		return attachment
	}
}