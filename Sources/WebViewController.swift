//
//  WebViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 1/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import SafariServices

final class WebViewController: SFSafariViewController {

	// MARK: - Properties

	let originalURL: NSURL


	// MARK: - Initializers

	convenience init(URL: NSURL) {
		self.init(URL: URL, entersReaderIfAvailable: false)
	}

	override init(URL: NSURL, entersReaderIfAvailable: Bool) {
		originalURL = URL
		super.init(URL: URL, entersReaderIfAvailable: entersReaderIfAvailable)
	}


	// MARK: - UIViewController

	override func previewActionItems() -> [UIPreviewActionItem] {
		let copyAction = UIPreviewAction(title: "Copy URL", style: .Default) { [weak self] _, _ in
			UIPasteboard.generalPasteboard().URL = self?.originalURL
		}

		let safariAction = UIPreviewAction(title: "Open in Safari", style: .Default) { [weak self] _, _ in
			guard let URL = self?.originalURL else { return }
			UIApplication.sharedApplication().openURL(URL)
		}

		return [copyAction, safariAction]
	}
}
