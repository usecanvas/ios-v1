//
//  CanvasTextView+Annotations.swift
//  Canvas
//
//  Created by Sam Soffes on 12/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

extension CanvasTextView {
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
}
