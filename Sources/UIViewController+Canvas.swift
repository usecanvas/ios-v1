//
//  UIViewController+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 5/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
	func dismissDetailViewController(sender: AnyObject?) {
		if let splitViewController = splitViewController where !splitViewController.collapsed {
			splitViewController.dismissDetailViewController(sender)
			return
		}

		if let presenter = targetViewControllerForAction(#selector(dismissDetailViewController), sender: sender) {
			presenter.dismissDetailViewController(self)
		}
	}
}


extension UINavigationController {
	override func dismissDetailViewController(sender: AnyObject?) {
		popViewControllerAnimated(true)
	}
}


extension UISplitViewController {
	override func dismissDetailViewController(sender: AnyObject?) {
		showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: sender)
	}
}
