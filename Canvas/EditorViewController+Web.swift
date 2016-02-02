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

	private func showError(errorMessage errorMessage: String?, lineNumber: UInt? = nil, columnNumber: UInt? = nil) {
		// Disable editing
		textView.editable = false

		// Report error
		Rollbar.report(errorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber, account: account)

		// Show alert
		let alert = UIAlertController(title: "We're still a bit buggy and hit a wall. We've reported the error and disabled the editor to prevent data loss.", message: errorMessage, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Reload", style: .Default, handler: { [weak self] _ in
			self?.textStorage.reconnect()
		}))
		presentViewController(alert, animated: true, completion: nil)
	}
}
