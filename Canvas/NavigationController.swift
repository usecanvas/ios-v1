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

	private func updateTintColor(viewController: UIViewController) {
		let tintColor = (viewController as? TintableEnvironment)?.preferredTintColor
		updateTintColor(tintColor)
	}

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
		// Call didShow if the animation is canceled
		transitionCoordinator()?.notifyWhenInteractionEndsUsingBlock { [weak self] context in
			guard context.isCancelled() else { return }
			guard let delegate = self, from = context.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
			delegate.navigationController(navigationController, willShowViewController: from, animated: animated)

			let animationCompletion = context.transitionDuration() * NSTimeInterval(context.percentComplete())
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animationCompletion) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
				delegate.navigationController(navigationController, didShowViewController: from, animated: animated)
			}
		}

		updateTintColor(viewController)
	}

	func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
		updateTintColor(viewController)
	}
}
