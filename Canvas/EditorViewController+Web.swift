//
//  EditorViewController+Web.swift
//  Canvas
//
//  Created by Sam Soffes on 2/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import WebKit
import CanvasText

extension EditorViewController: CanvasWebDelegate {
	func textStorage(textStorage: CanvasTextStorage, willConnectWithWebView webView: WKWebView) {
		webView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
		view.addSubview(webView)
	}

	func textStorage(textStorage: CanvasTextStorage, didReceiveWebErrorMessage errorMessage: String?, lineNumber: UInt?, columnNumber: UInt?) {
		showError(errorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber)
	}

	func textStorage(textStorage: CanvasTextStorage, didDisconnectWithErrorMessage errorMessage: String?) {
		showError(errorMessage: errorMessage)
	}

	func textStorageDidConnect(textStorage: CanvasTextStorage) {
		if wantsFocus {
			textView.becomeFirstResponder()
			wantsFocus = false
		}
	}

	private func showError(errorMessage errorMessage: String?, lineNumber: UInt? = nil, columnNumber: UInt? = nil) {
		// Disable editing
		let focused = textView.isFirstResponder()
		textView.resignFirstResponder()

		// Report error
		Rollbar.report(errorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber, account: account)

		// Show alert
		let alert = UIAlertController(title: "We're still a bit buggy and hit a wall. We've reported the error and disabled the editor to prevent data loss.", message: errorMessage, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Reload", style: .Default, handler: { [weak self] _ in
			self?.textStorage.reconnect()
			self?.wantsFocus = focused
		}))

		// TODO: Terrible hack to prevent the keyboard from coming back up right after the alert is dismissed.
		let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2))
		dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
			self?.textView.editable = false
			self?.presentViewController(alert, animated: true, completion: nil)
		}
	}
}
