//
//  EditorView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class EditorView: UITextView {
	
//	// MARK: - Properties
//	
//	let collectionID: String
//	let canvasID: String
//	
//	private let shareController: ShareController
//	
//	
//	// MARK: - Initializers
//	
//	init(collectionID: String, canvasID: String) {
//		self.collectionID = collectionID
//		self.canvasID = canvasID
//		shareController = ShareController(collectionID: collectionID, canvasID: canvasID)
//		
//		super.init(frame: .zero, textContainer: nil)
//		
//		textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//		font = .systemFontOfSize(16)
//		alwaysBounceVertical = true
//		
//		delegate = self
//		shareController.delegate = self
//	}
//
//	required init?(coder aDecoder: NSCoder) {
//	    fatalError("init(coder:) has not been implemented")
//	}
//}
//
//
//extension EditorView: ShareControllerDelegate {
//	func shareController(controller: ShareController, didReceiveOp op: Op) {
//		var selection = self.selectedRange
//		var text = self.text
//		
//		switch op {
//		case .Insert(let location, let string):
//			// Shift selection
//			let length = string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
//			if Int(location) < selection.location {
//				selection.location += string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
//			}
//			
//			// Extend selection
//			selection.length += NSIntersectionRange(selection, NSRange(location: Int(location), length: length)).length
//			
//			// Update text
//			let index = text.startIndex.advancedBy(Int(location))
//			let range = Range<String.Index>(start: index, end: index)
//			text = text.stringByReplacingCharactersInRange(range, withString: string)
//		case .Delete(let location, let length):
//			// Shift selection
//			if Int(location) < selection.location {
//				selection.location -= Int(length)
//			}
//			
//			// Extend selection
//			selection.length -= NSIntersectionRange(selection, NSRange(location: Int(location), length: Int(length))).length
//			
//			// Update text
//			let index = text.startIndex.advancedBy(Int(location))
//			let range = Range<String.Index>(start: index, end: index.advancedBy(Int(length)))
//			text = text.stringByReplacingCharactersInRange(range, withString: "")
//		}
//		
//		// Apply changes
//		self.text = text
//		self.selectedRange = selection
//	}
//	
//	func shareController(controller: ShareController, didReceiveSnapshot text: String) {
//		self.text = text
//		self.editable = true
//	}
//}
//
//
//extension EditorView: UITextViewDelegate {
//	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//		// Insert
//		if range.length == 0 {
//			shareController.insert(location: UInt(range.location), string: text)
//		}
//			
//			// Delete
//		else {
//			shareController.delete(location: UInt(range.location), length: UInt(range.length))
//		}
//		
//		return true
//	}
}
