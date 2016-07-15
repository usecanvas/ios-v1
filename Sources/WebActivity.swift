//
//  WebActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 11/18/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class WebActivity: UIActivity {

	// MARK: - Properties

	var URL: NSURL?
	var schemePrefix: String?


	// MARK: - UIActivity

	override func prepareWithActivityItems(activityItems: [AnyObject]) {
		for activityItem in activityItems {
			if let URL = activityItem as? NSURL {
				self.URL = URL
				return
			}
		}
	}
}
