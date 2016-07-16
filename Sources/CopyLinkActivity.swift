//
//  CopyLinkActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 7/15/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

// TODO: Localize
final class CopyLinkActivity: UIActivity {

	// MARK: - Properties

	private var url: NSURL?


	// MARK: - UIActivity

	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
		guard let url = activityItems.first as? NSURL else { return false }

		self.url = url
		return true
	}

	override func performActivity() {
		UIPasteboard.generalPasteboard().URL = url
		showBanner(text: "Copied link!")
	}

	override func activityType() -> String? {
		return "copy-link"
	}

	override func activityTitle() -> String? {
		return "Copy Link"
	}

	override func activityImage() -> UIImage? {
		return UIImage(named: "Copy Link")
	}
}
