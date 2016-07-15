//
//  ChromeActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class ChromeActivity: WebActivity {

	// MARK: - UIActivity

	override func activityType() -> String? {
		return "open-in-chrome"
	}

	override func activityTitle() -> String? {
		return "Open in Chrome"
	}

	override func activityImage() -> UIImage? {
		return UIImage(named: "Chrome")
	}

	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
		for activityItem in activityItems {
			if let activityURL = activityItem as? NSURL, chromeScheme = chromeSchemeForURL(activityURL), chromeURL = NSURL(string: "\(chromeScheme)://") where UIApplication.sharedApplication().canOpenURL(chromeURL) {
				return true
			}
		}

		return false
	}

	override func performActivity() {
		guard let URL = self.URL else {
			activityDidFinish(false)
			return
		}


		guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true),
			chromeScheme = chromeSchemeForURL(URL)
			else {
				activityDidFinish(false)
				return
		}

		components.scheme = chromeScheme

		let completed = components.URL.flatMap { UIApplication.sharedApplication().openURL($0) } ?? false
		activityDidFinish(completed)
	}


	// MARK: - Private

	private func chromeSchemeForURL(URL: NSURL) -> String? {
		if URL.scheme == "http" {
			return "googlechrome"
		}

		if URL.scheme == "https" {
			return "googlechromes"
		}
		
		return nil
	}
}
