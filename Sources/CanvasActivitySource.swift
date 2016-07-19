//
//  CanvasActivitySource.swift
//  Canvas
//
//  Created by Sam Soffes on 7/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit

final class CanvasActivitySource: NSObject {

	// MARK: - Properties

	private let title: String
	private let url: NSURL


	// MARK: - Initializers

	init?(canvas: Canvas) {
		guard let url = canvas.url else { return nil }

		title = canvas.title
		self.url = url

		super.init()
	}
}


extension CanvasActivitySource: UIActivityItemSource {
	func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
		return url
	}

	func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
		switch activityType {
		case UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePostToTencentWeibo:
			return "\(title) — \(url)"
		case UIActivityTypeAirDrop:
			return url
		default:
			return url
		}
	}

	func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
		// TODO: Localize
		return "Check out this Canvas"
	}
}
