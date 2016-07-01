//
//  NavigationController.swift
//  Canvas
//
//  Created by Sam Soffes on 1/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class NavigationController: UINavigationController {

	// MARK: - Properties

	private let defaultTintColor = Swatch.brand
	private let defaultTitleColor = Swatch.black


	// MARK: - Initializers

	override init(rootViewController: UIViewController) {
		super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)

		viewControllers = [rootViewController]

		updateTintColor(view.tintColor)

		delegate = self
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Private

	private func updateTintColor(viewController: UIViewController) {
		var target = viewController

		// Handle nested navigation controllers for when the split view is collapsed
		if let top = (viewController as? UINavigationController)?.topViewController {
			target = top
		}

		let tintColor = (target as? TintableEnvironment)?.preferredTintColor
		updateTintColor(tintColor)
	}

	private func updateTintColor(tintColor: UIColor?) {
		let itemsColor = tintColor ?? defaultTintColor
		view.tintColor = itemsColor
		navigationBar.tintColor = itemsColor
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
