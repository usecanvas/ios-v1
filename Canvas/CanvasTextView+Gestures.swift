//
//  CanvasTextView+Gestures.swift
//  Canvas
//
//  Created by Sam Soffes on 12/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

extension CanvasTextView {
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
}
