//
//  EditorViewController+Actions.swift
//  Canvas
//
//  Created by Sam Soffes on 5/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension EditorViewController {
	func close(sender: UIAlertAction? = nil) {
		NSNotificationCenter.defaultCenter().postNotificationName(EditorViewController.willCloseNotificationName, object: nil)
		dismissDetailViewController(self)
	}
	
	func dismissKeyboard(sender: AnyObject?) {
		textView.resignFirstResponder()
	}
	
	func share(sender: AnyObject?) {
		dismissKeyboard(sender)
		
		guard let URL = canvas.URL else { return }
		let activities = [SafariActivity(), ChromeActivity()]
		let viewController = UIActivityViewController(activityItems: [URL], applicationActivities: activities)
		
		if let popover = viewController.popoverPresentationController {
			if let button = sender as? UIBarButtonItem {
				popover.barButtonItem = button
			} else {
				popover.sourceView = view
			}
		}
		
		presentViewController(viewController, animated: true, completion: nil)
	}
	
	func check() {
		textController.toggleChecked()
	}
	
	func indent() {
		textController.indent()
	}
	
	func outdent() {
		textController.outdent()
	}
	
	func bold() {
		textController.bold()
	}
	
	func italic() {
		textController.italic()
	}
	
	func inlineCode() {
		textController.inlineCode()
	}
	
	func insertLineAfter() {
		textController.insertLineAfter()
	}
	
	func insertLineBefore() {
		textController.insertLineBefore()
	}
	
	func deleteLine() {
		textController.deleteLine()
	}
	
	func reload(sender: UIAlertAction? = nil) {
		textController.connect()
	}
}
