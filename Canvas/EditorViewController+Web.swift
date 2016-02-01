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

	func textStorage(textStorage: CanvasTextStorage, didReceiveWebErrorMessage errorMessage: String, lineNumber: UInt?, columnNumber: UInt?) {
		Rollbar.report(errorMessage: errorMessage, lineNumber: lineNumber, columnNumber: columnNumber, account: account)
	}
}
