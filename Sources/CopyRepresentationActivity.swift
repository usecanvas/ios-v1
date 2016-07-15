//
//  CopyRepresentationActivity.swift
//  Canvas
//
//  Created by Sam Soffes on 7/15/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class CopyRepresentationActivity: UIActivity {

	// MARK: - Types

	enum Representation: String {
		case markdown
		case html
		case json

		var activityType: String {
			return "copy-\(rawValue)"
		}

		// TODO: Localize
		var activityTitle: String {
			switch self {
			case .markdown: return "Copy Markdown"
			case .html: return "Copy HTML"
			case .json: return "Copy JSON"
			}
		}

		var activityImage: UIImage? {
			switch self {
			case .markdown: return UIImage(named: "Copy Markdown")
			case .html: return UIImage(named: "Copy HTML")
			case .json: return UIImage(named: "Copy JSON")
			}
		}
	}


	// MARK: - Properties

	let representation: Representation


	// MARK: - Initializers

	init(representation: Representation) {
		self.representation = representation
		super.init()
	}


	// MARK: - UIActivity

	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
		// TODO: Implement
		return true
	}

	override func activityType() -> String? {
		return representation.activityType
	}

	override func activityTitle() -> String? {
		return representation.activityTitle
	}

	override func activityImage() -> UIImage? {
		return representation.activityImage
	}
}
