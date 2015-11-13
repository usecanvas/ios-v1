//
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import CanvasText

class EditorViewController: UIViewController {
	
	// MARK: - Properties

	let canvas: Canvas
	
	let textView: UITextView = {
		let view = UITextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 32, right: 16)
		view.alwaysBounceVertical = true
		view.editable = false
		return view
	}()
	
	private let textController = TextController()


	// MARK: - Initializers

	init(canvas: Canvas) {
		self.canvas = canvas
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIResponder

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand] {
		return [
			UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: "dismissKeyboard:")
		]
	}

	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .whiteColor()
		
		textView.delegate = self
		view.addSubview(textView)
		
		NSLayoutConstraint.activateConstraints([
			textView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			textView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			textView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
			textView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
		])
		
		textController.delegate = self
		textController.connect(collectionID: canvas.collectionID, canvasID: canvas.ID)
	}


	// MARK: - Actions

	@objc private func dismissKeyboard(sender: AnyObject?) {
		textView.resignFirstResponder()
	}
}


extension EditorViewController: UITextViewDelegate {
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		textController.change(range: range, replacementText: text)
		return true
	}
	
	func textViewDidChangeSelection(textView: UITextView) {
		textController.backingSelection = textController.displayRangeToBackingRange(textView.selectedRange)
	}
}


extension EditorViewController: TextControllerDelegate {
	func textControllerDidChangeText(textController: TextController) {
		textView.editable = true
		
		let text = NSMutableAttributedString(string: textController.displayText, attributes: Theme.baseAttributes)
		
		for line in textController.lines {
			let attributes = Theme.attributesForLine(line)
			let range = textController.backingRangeToDisplayRange(line.contentRange)
			text.addAttributes(attributes, range: range)
		}
		
		textView.attributedText = text
	}
	
	func textControllerDidUpdateSelection(textController: TextController) {
		textView.selectedRange = textController.displaySelection
	}
}
