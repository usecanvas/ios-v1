//
//  EditorViewController+Connection.swift
//  Canvas
//
//  Created by Sam Soffes on 5/31/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import SentrySwift
import CanvasText

extension EditorViewController: TextControllerConnectionDelegate {
	func textController(textController: TextController, willConnectWithWebView webView: WKWebView) {
		webView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
		view.addSubview(webView)
	}

	func textControllerDidConnect(textController: TextController) {
		presenceController.setCanvas(canvasID: canvas.ID)

		if canvas.isWritable {
			textView.editable = true
		}

		updateTitlePlaceholder()

		if textView.editable && (usingKeyboard || textView.text.isEmpty) {
			textView.becomeFirstResponder()
		}
	}

	func textController(textController: TextController, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		textView.editable = false

		var dictionary = [String: AnyObject]()
		var message = errorMessage ?? "Unknown error."
		message += " "

		if let lineNumber = lineNumber {
			dictionary["line_number"] = lineNumber
			message += "\(lineNumber):"
		} else {
			message += "?:"
		}

		if let columnNumber = columnNumber {
			dictionary["column_number"] = columnNumber
			message += "\(columnNumber)"
		} else {
			message += "?"
		}

		let event = Event.build("CanvasNativeWrapper Error") {
			$0.level = .Error

			var dictionary = [String: AnyObject]()

			if let errorMessage = errorMessage {
				dictionary["error_message"] = errorMessage
			}

			if let lineNumber = lineNumber {
				dictionary["line_number"] = lineNumber
			}

			if let columnNumber = columnNumber {
				dictionary["column_number"] = columnNumber
			}

			if !dictionary.isEmpty {
				$0.extra = dictionary
			}
		}

		SentryClient.shared?.captureEvent(event)

		let completion = { [weak self] in
			self?.textController.disconnect(reason: "wrapper-error")
		}

		#if INTERNAL
			let alert = UIAlertController(title: "CanvasNativeWrapper Error", message: message, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: LocalizedString.Okay.string, style: .Cancel) { _ in
				completion()
				})
			presentViewController(alert, animated: true, completion: nil)
		#else
			completion()
		#endif
	}

	func textController(textController: TextController, didDisconnectWithErrorMessage errorMessage: String?) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false

		title = LocalizedString.Disconnected.string

		let state = usingKeyboard
		textView.editable = false
		usingKeyboard = state

		let message: String
		if errorMessage == "wrapper-error" {
			message = "We’re still a bit buggy and hit a wall. We’ve reported the error."
		} else {
			message = "The connection to Canvas was lost."
		}

		let alert = UIAlertController(title: "Disconnected", message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Close Canvas", style: .Destructive, handler: close))
		alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: reload))
		presentViewController(alert, animated: true, completion: nil)
	}
}
