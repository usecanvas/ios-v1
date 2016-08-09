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
import Intercom

final class RootViewController: UIViewController {

	// MARK: - Properties

	var account: Account? {
		didSet {
			guard let account = account else {
				SentryClient.shared?.user = nil
				Intercom.reset()
				NSUserDefaults.standardUserDefaults().removeObjectForKey("SelectedOrganization")

				viewController = OnboardingViewController()
				return
			}

			// Update Sentry
			SentryClient.shared?.user = User(id: account.user.id, email: account.email, username: account.user.username)

			// Update Intercom
			Intercom.registerUserWithUserId(account.user.id)
			
			var attributes: [String: AnyObject] = [
				"email": account.email,
			]
			
			if let username = account.user.username {
				attributes["username"] = username
			}
			
			if let url = account.user.avatarURL?.absoluteString {
				attributes["avatar_url"] = url
			}
			
			Intercom.updateUserWithAttributes(attributes)

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


	// MARK: - Internal

	func _showBanner(text text: String, style: BannerView.Style = .success, inViewController viewController: UIViewController) {
		var top = viewController

		while let parent = top.parentViewController {
			top = parent
		}

		let container = top.view

		let banner = BannerView(style: style)
		banner.translatesAutoresizingMaskIntoConstraints = false
		banner.textLabel.text = text

		let mask = UIView()
		mask.translatesAutoresizingMaskIntoConstraints = false
		mask.clipsToBounds = true
		container.addSubview(mask)
		mask.addSubview(banner)

		// Split view makes this super annoying
		let navigationController = viewController.navigationController?.navigationController ?? viewController.navigationController
		let topAnchor = navigationController?.navigationBar.bottomAnchor ?? view.topAnchor
		let leadingAnchor = navigationController?.view.leadingAnchor ?? view.leadingAnchor
		let widthAnchor = navigationController?.view.widthAnchor ?? view.widthAnchor

		let outYConstraint = banner.bottomAnchor.constraintEqualToAnchor(topAnchor)
		outYConstraint.priority = UILayoutPriorityDefaultHigh

		let inYConstraint = banner.topAnchor.constraintEqualToAnchor(topAnchor)
		inYConstraint.priority = UILayoutPriorityDefaultLow

		NSLayoutConstraint.activateConstraints([
			outYConstraint,
			inYConstraint,
			banner.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			banner.widthAnchor.constraintEqualToAnchor(widthAnchor),

			mask.topAnchor.constraintEqualToAnchor(topAnchor),
			mask.leadingAnchor.constraintEqualToAnchor(banner.leadingAnchor),
			mask.widthAnchor.constraintEqualToAnchor(banner.widthAnchor),
			mask.heightAnchor.constraintEqualToAnchor(banner.heightAnchor)
		])
		banner.layoutIfNeeded()

		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {
			outYConstraint.active = false
			banner.layoutIfNeeded()
		}, completion: nil)

		UIView.animateWithDuration(0.3, delay: 2.3, options: [.BeginFromCurrentState, .CurveEaseInOut], animations: {
			outYConstraint.active = true
			banner.layoutIfNeeded()
		}, completion: { _ in
			mask.removeFromSuperview()
		})
	}


	// MARK: - Private

	@objc private func accountDidChange(notification: NSNotification?) {
		account = AccountController.sharedController.currentAccount

	}
}
