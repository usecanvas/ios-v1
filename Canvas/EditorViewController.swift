//
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class EditorViewController: UIViewController {
	
	// MARK: - Properties
	
	let textView: UITextView = {
		let view = UITextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.editable = false
		return view
	}()
	
	private let textController = TextController()
	
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
		textController.connect(collectionID: "10ef574f-7a70-4b21-8fb1-fec3c49f941b", canvasID: "1323fedf-4fda-4463-93d8-56f574f5d06a")
	}
}


extension EditorViewController: UITextViewDelegate {
	func textViewDidChangeSelection(textView: UITextView) {
		textController.backingSelection = textController.displayRangeToBackingRange(textView.selectedRange)
	}
}


extension EditorViewController: TextControllerDelegate {
	func textControllerDidChangeText(textController: TextController) {
		textView.editable = true
		
		let text = NSMutableAttributedString(string: textController.displayText, attributes: [
			NSFontAttributeName: UIFont.systemFontOfSize(16)
			])
		
		for line in textController.lines {
			let range = textController.backingRangeToDisplayRange(line.content)
			
			switch line.kind {
			case .DocHeading:
				text.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(18), range: range)
			case .Paragraph:
				text.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: range)
			default:
				text.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: range)
			}
		}
		
		textView.attributedText = text
	}
	
	func textControllerDidUpdateSelection(textController: TextController) {
		textView.selectedRange = textController.displaySelection
	}
}
