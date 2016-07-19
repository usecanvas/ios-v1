//
//  UIViewController+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 5/11/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
	func present(actionSheet actionSheet: UIViewController, sender: AnyObject?, animated: Bool = true, completion: (() -> Void)? = nil) {
		if let popover = actionSheet.popoverPresentationController {
			if let button = sender as? UIBarButtonItem {
				popover.barButtonItem = button
			} else if let sourceView = sender as? UIView {
				popover.sourceView = sourceView
			} else {
				popover.sourceView = view
			}
		}

		presentViewController(actionSheet, animated: animated, completion: completion)
	}

	func dismissDetailViewController(sender: AnyObject?) {
		if let splitViewController = splitViewController where !splitViewController.collapsed {
			splitViewController.dismissDetailViewController(sender)
			return
		}

		if let presenter = targetViewControllerForAction(#selector(dismissDetailViewController), sender: sender) {
			presenter.dismissDetailViewController(self)
		}
	}

	func showBanner(text text: String, style: BannerView.Style = .success) {
		guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? RootViewController else { return }
		rootViewController._showBanner(text: text, style: style, inViewController: self)

	}
}


extension UINavigationController {
	override func dismissDetailViewController(sender: AnyObject?) {
		// Hack to fix nested navigation controllers that split view makes. Ugh.
		if viewControllers.count == 1 {
			navigationController?.popViewControllerAnimated(true)
			return
		}
		popViewControllerAnimated(true)
	}
}


extension UISplitViewController {
	override func dismissDetailViewController(sender: AnyObject?) {
		showDetailViewController(NavigationController(rootViewController: PlaceholderViewController()), sender: sender)
	}
}
