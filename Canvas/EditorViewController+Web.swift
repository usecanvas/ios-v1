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
		// Report to Rollbar
		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.rollbar.com/api/1/item/")!)
		request.HTTPMethod = "POST"

		var data: [String: AnyObject] = [
			"level": "error",
			"timestamp": UInt(NSDate().timeIntervalSince1970),
			"platform": "ios",
			"language": "javascript",
			"context": "editor.html",
			"person": [
				"id": account.user.ID,
				"username": account.user.username,
				"email": account.email
			],
			"notifier": [
				"name": "canvas-ios"
			]
		]

		#if DEBUG
			data["environment"] = "development"
		#else
			data["environment"] = "production"
		#endif

		if let lineNumber = lineNumber, columnNumber = columnNumber {
			data["body"] = [
				"trace": [
					"frames": [
						"filename": "editor.html",
						"lineno": lineNumber,
						"colno": columnNumber
					],
					"exception": [
						"class": "Error",
						"message": errorMessage
					]
				]
			]
		} else {
			data["body"] = [
				"message": errorMessage
			]
		}

		if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? UInt {
			data["code_version"] = version
		}

		let payload = [
			"access_token": Config.rollbarToken,
			"data": data
		]

		request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(payload, options: [])

		NSURLSession.sharedSession().dataTaskWithRequest(request).resume()
	}
}
