//
//  SafariActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class SafariActivity: WebActivity {

	// MARK: - UIActivity

	override func activityType() -> String? {
		return "open-in-safari"
	}

	override func activityTitle() -> String? {
		return "Open in Safari"
	}

	override func activityImage() -> UIImage? {
		return UIImage(named: "Safari")
	}

	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
		for activityItem in activityItems {
			if let URL = activityItem as? NSURL where UIApplication.sharedApplication().canOpenURL(URL) {
				return true
			}
		}

		return false
	}

	override func performActivity() {
		let completed = URL.flatMap { UIApplication.sharedApplication().openURL($0) } ?? false
		activityDidFinish(completed)
	}
}
