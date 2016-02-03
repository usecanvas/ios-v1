//
//  Rollbar.swift
//  Canvas
//
//  Created by Sam Soffes on 2/1/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import CanvasKit

// CanvasText web view specific Rollbar reporting.
struct Rollbar {
	static func report(errorMessage errorMessage: String?, lineNumber: UInt? = nil, columnNumber: UInt? = nil, account: Account? = nil) {
		#if DEBUG
			print("[CanvasText] JavaScript error: \(errorMessage), lineNumber: \(lineNumber), columnNumber: \(columnNumber)")
		#else
			// Report to Rollbar
			let request = NSMutableURLRequest(URL: NSURL(string: "https://api.rollbar.com/api/1/item/")!)
			request.HTTPMethod = "POST"

			var data: [String: AnyObject] = [
				"level": "error",
				"timestamp": UInt(NSDate().timeIntervalSince1970),
				"platform": "ios",
				"language": "javascript",
				"context": "editor.html",
				"environment": "production",
				"notifier": [
					"name": "canvas-ios"
				]
			]

			if let account = account {
				data["person"] = [
					"id": account.user.ID,
					"username": account.user.username,
					"email": account.email
				]
			}

			if let lineNumber = lineNumber, columnNumber = columnNumber {
				data["body"] = [
					"trace": [
						"frames": [
							[
								"filename": "editor.html",
								"lineno": lineNumber,
								"colno": columnNumber
							]
						],
						"exception": [
							"class": "Error",
							"message": errorMessage ?? ""
						]
					]
				]
			} else {
				data["body"] = [
					"message": errorMessage ?? ""
				]
			}

			if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? UInt {
				data["code_version"] = version
			}

			let payload = [
				"access_token": Config.rollbarToken,
				"data": data
			]

			// Add JSON to request
			request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(payload, options: [])

			// Request
			NSURLSession.sharedSession().dataTaskWithRequest(request).resume()
		#endif
	}
}
