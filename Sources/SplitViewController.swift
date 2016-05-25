//
//  SplitViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/17/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

	// MARK: - UIViewController

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Work around wrong automatic primary column calculatations by UISplitViewController
		guard let window = view.window else { return }

		let screen = window.screen
		let width: CGFloat

		if window.bounds.width < screen.bounds.width {
			width = 258
		} else {
			width = window.bounds.width > 1024 ? 375 : 320
		}

		minimumPrimaryColumnWidth = width
		maximumPrimaryColumnWidth = width
	}

	override func showViewController(viewController: UIViewController, sender: AnyObject?) {
		// Prevent weird animation *sigh*
		UIView.performWithoutAnimation {
			super.showViewController(viewController, sender: sender)
		}
	}
}


extension UISplitViewController {
	convenience init(masterViewController: UIViewController, detailViewController: UIViewController) {
		self.init()
		viewControllers = [masterViewController, detailViewController]
	}

	var masterViewController: UIViewController? {
		return viewControllers.first
	}

	var detailViewController: UIViewController? {
		guard viewControllers.count == 2 else { return nil }
		return viewControllers.last
	}
}
