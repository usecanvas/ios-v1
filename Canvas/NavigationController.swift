//
//  NavigationController.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

	// MARK: - Properties

	var tintColor: UIColor {
		get {
			return view.tintColor
		}

		set {
			view.tintColor = newValue
		}
	}


	// MARK: - Initializers

	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)

		navigationBar.barTintColor = .whiteColor()
		navigationBar.translucent = false
		navigationBar.shadowImage = UIImage()
//		navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)

		tintColorDidChange()

		addObserver(self, forKeyPath: "view.tintColor", options: [.New], context: nil)
	}

	// TODO: Remove
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		removeObserver(self, forKeyPath: "view.tintColor")
	}


	// MARK: - NSKeyValueObserving

	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "view.tintColor" {
			tintColorDidChange()
			return
		}

		super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
	}


	// MARK: - Private

	private func tintColorDidChange() {
		navigationBar.tintColor = tintColor
		navigationBar.titleTextAttributes = [
			NSFontAttributeName: Font.sansSerif(weight: .Bold),
			NSForegroundColorAttributeName: tintColor
		]
	}
}
