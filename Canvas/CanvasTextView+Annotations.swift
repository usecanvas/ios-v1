//
//  CanvasTextView+Annotations.swift
//  Canvas
//
//  Created by Sam Soffes on 12/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText
import CanvasNative

private let keywordMap = [
	"workbench": "brush",
	"planning": "event",
	"discussion": "forum",
	"meeting": "forum",
	"okr": "insert_chart",
	"okrs": "insert_chart",
	"investor": "insert_chart",
	"todo": "list",
	"checklist": "list",
	"mockup": "photo",
	"log": "receipt"
]

extension CanvasTextView {
	func removeAnnotations() {
		annotations.forEach { $0.removeFromSuperview() }
		annotations.removeAll()
	}
	
	func updateAnnotations() {
		guard let textStorage = textStorage as? CanvasTextStorage else { return }

		lineNumber = 1

		let origin = CGPoint(x: textContainer.lineFragmentPadding + textContainerInset.left, y: textContainerInset.top)

		iconView.frame = CGRect(
			x: origin.x,
			y: origin.y + 14, // TODO: Get from line height
			width: 24,
			height: 24
		)
		iconView.image = UIImage(named: "description")

		// Placeholder

		// TODO: Use the AST to figure this out
		if let title = textStorage.nodes.first as? Title where title.displayRange.length == 0 {
			addSubview(placeholderLabel)
			annotations.append(placeholderLabel)

			placeholderLabel.sizeToFit()

			var frame = placeholderLabel.frame
			frame.origin = origin

			// TODO: Align with new annotation system
			frame.origin.x = iconView.frame.maxX + 7.5

			// TODO: Properly size to fit
			frame.size.width = bounds.size.width

			placeholderLabel.frame = frame
			return
		}

		// Add annotations
		let needsFirstResponder = !isFirstResponder()
		if needsFirstResponder {
			becomeFirstResponder()
		}

		// Make sure the layout is ready since we calculate annotations based off of that
		layoutManager.ensureLayoutForTextContainer(textContainer)

		var orderedIndentationCounts = [Indentation: UInt]()

		let count = textStorage.nodes.count
		for (i, node) in textStorage.nodes.enumerate() {
			if node is Title {
				for word in node.contentInString(textStorage.backingText).componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
					if let imageName = keywordMap[word.lowercaseString] {
						iconView.image = UIImage(named: imageName)
						break
					}
				}
			}

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
				if let node = node as? OrderedListItem {
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

		// TODO: Use the font for the given node
		let font = theme.fontOfSize(theme.fontSize, style: [])

		// Unordered List
		if let node = node as? UnorderedListItem {
			let view = BulletView(frame: .zero, unorderedList: node)
			let size = view.intrinsicContentSize()

			rect.origin.x = floor(rect.origin.x - theme.listIndentation + (size.width / 2))
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect

			return view
		}

		// Ordered list
		if let node = node as? OrderedListItem {
			let value = orderedIndentationCounts[node.indentation] ?? 1
			let view = NumberView(frame: .zero, theme: theme, value: value)
			view.sizeToFit()

			let size = view.bounds.size
			let baseline = rect.maxY + font.descender
			let numberBaseline = size.height + view.font!.descender
			let scale = window!.screen.scale

			rect.origin.x = floor(rect.origin.x - size.width - 4)
			rect.origin.y = ceil((baseline - numberBaseline) * scale) / scale
			rect.size = size
			view.frame = rect

			return view
		}

		// ChecklistItem
		if let node = node as? ChecklistItem {
			let view = CheckboxView(frame: .zero, checklist: node)
			view.addTarget(self, action: "toggleCheckbox:", forControlEvents: .TouchUpInside)
			let size = view.intrinsicContentSize()
			rect.origin.x = floor(rect.origin.x - theme.listIndentation - size.width + 16)
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))

			// TODO: Hack
			if node.displayRange.length == 0 {
				rect.origin.y -= 1
			}

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
			if let next = nextSibling as? Blockquote, let nextRect = firstRectForNode(next) {
				rect.size.height = nextRect.origin.y - rect.origin.y
			}

			// Extend to the end of the node
			else if let last = lastRectForNode(node) {
				rect.size.height = last.maxY - rect.origin.y
			}


			view.frame = rect

			return view
		}

		// Code block
		if let node = node as? CodeBlock {
			if traitCollection.horizontalSizeClass == .Compact {
				rect.origin.x = 0
				rect.size.width = bounds.width
			} else {
				rect.origin.x -= 48
				rect.size.width = textContainer.size.width
			}

			let originalTop = rect.origin.y

			// Find the bottom of line (to handle wrapping)
			var displayRange = textStorage.backingRangeToDisplayRange(node.displayRange)
			if displayRange.length > 1 {
				displayRange.location += displayRange.length - 1
				displayRange.length = 1
			}

			if let lastRect = firstRectForDisplayRange(displayRange) where lastRect.origin.y > originalTop {
				rect.size.height += lastRect.origin.y - originalTop
			}

			// Top
//			if !(previousSibling is CodeBlock) {
//				position = position.union([.Top])
//				rect.origin.y -= theme.paragraphSpacing / 4
//				rect.size.height += theme.paragraphSpacing / 4
//			}

			// Bottom
//			if !(nextSibling is CodeBlock) {
//				position = position.union([.Bottom])
//				rect.size.height += theme.paragraphSpacing / 2
//			}

			let view = CodeBlockBackgroundView(frame: rect.floor, theme: textStorage.theme, lineNumber: lineNumber, position: node.position)

			if node.position.isBottom {
				lineNumber = 1
			} else {
				lineNumber += 1
			}
			
			return view
		}
		
		return nil
	}
}
