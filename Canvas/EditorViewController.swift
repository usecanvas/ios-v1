//
//  EditorViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {
	
	// MARK: - Properties
	
	let shareController = ShareController(collectionID: "10ef574f-7a70-4b21-8fb1-fec3c49f941b", canvasID: "8ba16638-3ce8-4f14-a1b6-6d16bf0bcc18")
	
	let textView: UITextView = {
		let view = UITextView()
		view.textContainerInset = UIEdgeInsets(top: 36, left: 16, bottom: 16, right: 16)
		view.font = .systemFontOfSize(16)
		view.editable = false
		view.alwaysBounceVertical = true
		return view
	}()
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		shareController.delegate = self

		textView.frame = view.bounds
		view.addSubview(textView)
	}
}


extension EditorViewController: ShareControllerDelegate {
	func shareController(controller: ShareController, didReceiveOp op: Op) {
		var selection = textView.selectedRange
		var text = textView.text
		
		switch op {
		case .Insert(let location, let string):
			let length = string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			if Int(location) < selection.location {
				selection.location += string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			}
			
			selection.length += NSIntersectionRange(selection, NSRange(location: Int(location), length: length)).length
			
			let index = text.startIndex.advancedBy(Int(location))
			let range = Range<String.Index>(start: index, end: index)
			text = text.stringByReplacingCharactersInRange(range, withString: string)
		case .Delete(let location, let length):
			if Int(location) < selection.location {
				selection.location -= Int(length)
			}
			
			selection.length -= NSIntersectionRange(selection, NSRange(location: Int(location), length: Int(length))).length
			
			let index = text.startIndex.advancedBy(Int(location))
			let range = Range<String.Index>(start: index, end: index.advancedBy(Int(length)))
			text = text.stringByReplacingCharactersInRange(range, withString: "")
		}

		textView.text = text
		textView.selectedRange = selection
	}
	
	func shareController(controller: ShareController, didReceiveSnapshot text: String) {
		// Assume we don't have a selection yet
		textView.text = text
	}
}