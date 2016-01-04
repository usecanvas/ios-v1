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

	func registerGestureRecognizers() {
		let indent = UISwipeGestureRecognizer(target: self, action: "increaseBlockLevelWithGesture:")
		indent.numberOfTouchesRequired = 1
		indent.direction = .Right
		addGestureRecognizer(indent)

		let outdent = UISwipeGestureRecognizer(target: self, action: "decreaseBlockLevelWithGesture:")
		outdent.numberOfTouchesRequired = 1
		outdent.direction = .Left
		addGestureRecognizer(outdent)
	}


	// MARK: - Gestures

	@objc private func increaseBlockLevelWithGesture(sender: UISwipeGestureRecognizer?) {
		guard let sender = sender else { return }
		increaseBlockLevel(sender.locationInView(self))
	}

	@objc private func decreaseBlockLevelWithGesture(sender: UISwipeGestureRecognizer?) {
		guard let sender = sender else { return }
		decreaseBlockLevel(sender.locationInView(self))
	}

	private func increaseBlockLevel(point: CGPoint) {
		guard let textStorage = textStorage as? CanvasTextStorage,
			node = nodeAtPoint(point)
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

	private func decreaseBlockLevel(point: CGPoint) {
		guard let textStorage = textStorage as? CanvasTextStorage,
			node = nodeAtPoint(point)
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
