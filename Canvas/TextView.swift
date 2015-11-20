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

	private func addAnnotation(annotation: UIView) {
		annotations.append(annotation)
		addSubview(annotation)
	}

	private func annotationForNode(node: Node) -> UIView? {
		let range = textController.backingRangeToDisplayRange(node.contentRange)
		guard let start = positionFromPosition(beginningOfDocument, offset: range.location),
			end = positionFromPosition(start, offset: range.length),
			textRange = textRangeFromPosition(start, toPosition: end),
			font = font
		else { return nil }

		var rect = firstRectForRange(textRange)

		// Unordered List
		if let node = node as? UnorderedList {
			let view = BulletView(frame: .zero, unorderedList: node)
			let size = view.intrinsicContentSize()
			rect.origin.x -= Theme.listIndentation - (size.width / 2)
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect

			return view
		}

		// Ordered list
		if node is OrderedList {
			let view = NumberView(frame: .zero, value: 999)
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
			rect.origin.x -= Theme.listIndentation
			rect.origin.y = floor(rect.origin.y + font.ascender - (size.height / 2))
			rect.size = size
			view.frame = rect

			return view
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
				addAnnotation(annotation)
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
