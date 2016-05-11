//
//  RootViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import SentrySwift

final class RootViewController: UIViewController {

	// MARK: - Properties

	var account: Account? {
		didSet {
			guard let account = account else {
				SentryClient.shared?.user = nil
				viewController = LoginViewController()
				return
			}

			// Update Sentry
			SentryClient.shared?.user = User(id: account.user.ID, email: account.email, username: account.user.username)

			if var viewController = viewController as? Accountable {
				// TODO: Handle containers
				viewController.account = account
				return
			}

			let split = UISplitViewController()
			split.viewControllers = [
				NavigationController(rootViewController: OrganizationsViewController(account: account)),
				NavigationController(rootViewController: PlaceholderViewController())
			]
			split.preferredDisplayMode = .Automatic
			split.delegate = self

			viewController = split
		}
	}

	private(set) var viewController: UIViewController? {
		willSet {
			guard let viewController = viewController else { return }

			// Collapse the primary view controller if it's displaying
			if let splitViewController = viewController as? UISplitViewController {
				splitViewController.preferredDisplayMode = .PrimaryHidden
			}

			viewController.viewWillDisappear(false)
			viewController.view.removeFromSuperview()
			viewController.viewDidDisappear(false)
			viewController.removeFromParentViewController()
		}

		didSet {
			guard let viewController = viewController else { return }
			addChildViewController(viewController)

			viewController.view.translatesAutoresizingMaskIntoConstraints = false
			viewController.viewWillAppear(false)
			view.addSubview(viewController.view)

			NSLayoutConstraint.activateConstraints([
				viewController.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
				viewController.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
				viewController.view.topAnchor.constraintEqualToAnchor(view.topAnchor),
				viewController.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
			])
			viewController.viewDidAppear(false)

			setNeedsStatusBarAppearanceUpdate()
		}
	}


	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)

	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(accountDidChange), name: AccountController.accountDidChangeNotificationName, object: nil)
		accountDidChange(nil)
	}

	override func childViewControllerForStatusBarStyle() -> UIViewController? {
		return viewController
	}

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return traitCollection.userInterfaceIdiom == .Pad ? .All : .Portrait
	}


	// MARK: - Private

	@objc private func accountDidChange(notification: NSNotification?) {
		account = AccountController.sharedController.currentAccount
	}
}


extension RootViewController: UISplitViewControllerDelegate {
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
		return splitViewControllerIsEmpty(splitViewController, secondaryViewController: secondaryViewController)
	}

	func splitViewController(splitViewController: UISplitViewController, showDetailViewController viewController: UIViewController, sender: AnyObject?) -> Bool {
		guard splitViewController.viewControllers.count == 2 else { return false }

		if !(viewController is PlaceholderViewController) {
			viewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
			viewController.navigationItem.leftItemsSupplementBackButton = true
		}

		UIView.performWithoutAnimation {
			splitViewController.viewControllers[1] = NavigationController(rootViewController: viewController)
		}
		return true
	}

	func targetDisplayModeForActionInSplitViewController(splitViewController: UISplitViewController) -> UISplitViewControllerDisplayMode {
		switch splitViewController.displayMode {
		case .PrimaryOverlay, .PrimaryHidden: return .AllVisible
		default: return .PrimaryHidden
		}
	}

	private func splitViewControllerIsEmpty(splitViewController: UISplitViewController, secondaryViewController: UIViewController? = nil) -> Bool {
		let viewController = secondaryViewController ?? splitViewController.viewControllers.last
		if let secondaryNavigationController = viewController as? UINavigationController {
			return secondaryNavigationController.topViewController is PlaceholderViewController
		}

		return false
	}
}
