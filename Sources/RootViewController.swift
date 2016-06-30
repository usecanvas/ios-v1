//
//  RootViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/12/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import SentrySwift

final class RootViewController: UIViewController {

	// MARK: - Properties

	var account: Account? {
		didSet {
			guard let account = account else {
				SentryClient.shared?.user = nil
				NSUserDefaults.standardUserDefaults().removeObjectForKey("SelectedOrganization")
				let nav = UINavigationController(rootViewController: LogInViewController())
				nav.navigationBarHidden = true
				viewController = nav
				return
			}

			// Update Sentry
			SentryClient.shared?.user = User(id: account.user.id, email: account.email, username: account.user.username)

			if var viewController = viewController as? Accountable {
				// TODO: Handle containers
				viewController.account = account
				return
			}

			let masterViewController = NavigationController(rootViewController: OrganizationsViewController(account: account))

			let split = SplitViewController(
				masterViewController: masterViewController,
				detailViewController: NavigationController(rootViewController: PlaceholderViewController())
			)

			// Restore organization
			if let dictionary = NSUserDefaults.standardUserDefaults().objectForKey("SelectedOrganization") as? JSONDictionary, organization = Organization(dictionary: dictionary) {
				let viewController = OrganizationCanvasesViewController(account: account, organization: organization)
				masterViewController.pushViewController(viewController, animated: false)
			}

			viewController = split
		}
	}

	var viewController: UIViewController? {
		willSet {
			guard let viewController = viewController else { return }

			// Collapse the primary view controller if it's displaying
			if let splitViewController = viewController as? UISplitViewController {
				splitViewController.preferredDisplayMode = .PrimaryHidden
			}

			viewController.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)

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

			UIView.performWithoutAnimation {
				viewController.view.layoutIfNeeded()
			}

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
