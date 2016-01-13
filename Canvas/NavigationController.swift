//
//  NavigationController.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class NavigationController: UINavigationController {

	// MARK: - Properties

	private let defaultTintColor = Color.brand
	private let defaultTitleColor = Color.darkGray


	// MARK: - Initializers

	override init(rootViewController: UIViewController) {
		super.init(rootViewController: rootViewController)

		navigationBar.barTintColor = .whiteColor()
		navigationBar.translucent = false
		navigationBar.shadowImage = UIImage()

		updateTintColor(view.tintColor)

		delegate = self
	}

	// TODO: Remove
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	private func updateTintColor(tintColor: UIColor?) {
		let itemsColor = tintColor ?? defaultTintColor
		let titleColor = tintColor ?? defaultTitleColor

		view.tintColor = itemsColor
		navigationBar.tintColor = itemsColor
		navigationBar.titleTextAttributes = [
			NSFontAttributeName: Font.sansSerif(weight: .Bold),
			NSForegroundColorAttributeName: titleColor
		]
	}
}


extension NavigationController: UINavigationControllerDelegate {
	func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
		let tintColor = (viewController as? TintableEnvironment)?.preferredTintColor
		updateTintColor(tintColor)
	}
}
