//
//  CopyLinkActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 7/15/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class CopyLinkActivity: UIActivity {

	// MARK: - UIActivity

	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
		// TODO: Implement
		return true
	}

	override func activityType() -> String? {
		return "copy-link"
	}

	// TODO: Localize
	override func activityTitle() -> String? {
		return "Copy Link"
	}

	override func activityImage() -> UIImage? {
		return UIImage(named: "Copy Link")
	}
}
