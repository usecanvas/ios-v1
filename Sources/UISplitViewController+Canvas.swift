//
//  UISplitViewController+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 6/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

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
