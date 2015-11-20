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

class TextView: UITextView, Accountable {

	// MARK: - Properties

	var account: Account
	let canvas: Canvas
	private var annotations = [UIView]()
	private let textController = TextController()


	// MARK: - Initializers

	init(account: Account, canvas: Canvas) {
		self.account = account
		self.canvas = canvas

		super.init(frame: .zero, textContainer: nil)

		delegate = self
		textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
		alwaysBounceVertical = true
		editable = false
		tintColor = Color.brand
		textController.delegate = self

		textController.connect(accessToken: account.accessToken, collectionID: canvas.collectionID, canvasID: canvas.ID) { [weak self] webView in
			webView.alpha = 0.01
			self?.addSubview(webView)
		}

	}
	
	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	private func annotationForNode(node: Node) -> UIView? {
		let range = textController.backingRangeToDisplayRange(node.contentRange)
		guard let start = positionFromPosition(beginningOfDocument, offset: range.location),
			end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end)
		else { return nil }

		var rect = firstRectForRange(textRange)

		// Unordered List
		if let node = node as? UnorderedList {
			rect.origin.x -= Theme.listIndentation
			rect.origin.y += Theme.baseFontSize - 9 + 2.5 // Not sure about that + 2.5 &shrug
			rect.size = CGSize(width: 9, height: 9)

			return BulletView(frame: rect, unorderedList: node)
		}

		// Checklist
		if let node = node as? Checklist {
			rect.origin.x -= 12
			rect.origin.y += 3
			rect.size = CGSize(width: 16, height: 16)

			return CheckboxView(frame: rect, checklist: node)
		}

		return nil
	}
}


extension TextView: UITextViewDelegate {
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		textController.change(range: range, replacementText: text)
		return true
	}

	func textViewDidChangeSelection(textView: UITextView) {
		textController.backingSelection = textController.displayRangeToBackingRange(textView.selectedRange)
	}
}


extension TextView: TextControllerDelegate {
	func textControllerDidChangeText(textController: TextController) {
		editable = true

		annotations.forEach { $0.removeFromSuperview() }
		annotations.removeAll()

		let text = NSMutableAttributedString(string: textController.displayText, attributes: Theme.baseAttributes)

		let count = textController.nodes.count
		for (i, node) in textController.nodes.enumerate() {
			let next: Node?
			if i < count - 2 {
				next = textController.nodes[i + 1]
			} else {
				next = nil
			}

			// Add theme
			let attributes = Theme.attributesForNode(node, nextSibling: next)
			let range = textController.backingRangeToDisplayRange(node.contentRange)
			text.addAttributes(attributes, range: range)
		}

		self.attributedText = text

		// Add annotations
		let needsFirstResponder = !isFirstResponder()
		if needsFirstResponder {
			becomeFirstResponder()
		}

		for node in textController.nodes {
			if let annotation = annotationForNode(node) {
				annotations.append(annotation)
				addSubview(annotation)
			}
		}

		if needsFirstResponder {
			resignFirstResponder()
		}
	}

	func textControllerDidUpdateSelection(textController: TextController) {
		selectedRange = textController.displaySelection
	}
}
