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

	// TODO: Localize
	enum Representation: String {
		case markdown
		case html
		case json

		var activityType: String {
			return "copy-\(rawValue)"
		}

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

		var ext: String {
			return rawValue
		}

		var successMessage: String {
			switch self {
			case .markdown: return "Copied markdown!"
			case .html: return "Copied HTML!"
			case .json: return "Copied JSON!"
			}
		}

		var failureMessage: String {
			switch self {
			case .markdown: return "Failed to copy markdown."
			case .html: return "Failed to copy HTML."
			case .json: return "Failed to copy JSON."
			}
		}
	}


	// MARK: - Properties

	let representation: Representation
	let session: NSURLSession

	private var canvasID: String?


	// MARK: - Initializers

	init(representation: Representation, session: NSURLSession = NSURLSession.sharedSession()) {
		self.representation = representation
		self.session = session
		super.init()
	}


	// MARK: - UIActivity

	override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
		guard let url = activityItems.first as? NSURL else { return false }

		if url.host == "usecanvas.com", let components = url.pathComponents where components.count == 4 && (components[3] as NSString).length == 22 {
			canvasID = components[3]
			return true
		}

		return false
	}

	override func performActivity() {
		guard let canvasID = canvasID,
			url = NSURL(string: "https://usecanvas.com/-/-/\(canvasID).\(representation.ext)")
		else {
			showBanner(text: representation.failureMessage, style: .failure)
			return
		}

		let request = NSURLRequest(URL: url)
		session.dataTaskWithRequest(request) { [weak self] data, _, _ in
			guard let representation = self?.representation else{ return }
			let string = data.flatMap { String(data: $0, encoding: NSUTF8StringEncoding) }

			dispatch_async(dispatch_get_main_queue()) {
				if let string = string {
					UIPasteboard.generalPasteboard().string = string
					self?.showBanner(text: representation.successMessage)
				} else {
					self?.showBanner(text: representation.failureMessage, style: .failure)
				}
			}
		}.resume()
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
