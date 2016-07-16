//
//  UIActivity+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 7/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIActivity {
	func showBanner(text text: String, style: BannerView.Style = .success) {
		guard let rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? RootViewController,
			splitViewController = rootViewController.viewController as? SplitViewController,
			var viewController = splitViewController.viewControllers.last
		else { return }

		if let top = (viewController as? UINavigationController)?.topViewController {
			viewController = top
		}

		rootViewController._showBanner(text: text, style: style, inViewController: viewController)

	}
}
