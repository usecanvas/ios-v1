//
//  AppDelegate.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit
import SentrySwift

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties

	var window: UIWindow?


	// MARK: - Private

	private func showPersonalNotes(completion: OrganizationCanvasesViewController? -> Void) {
		guard let rootViewController = window?.rootViewController as? RootViewController,
			splitViewController = rootViewController.viewController as? UISplitViewController,
			navigationController = splitViewController.masterViewController as? UINavigationController
		else {
			completion(nil)
			return
		}

		navigationController.popToRootViewControllerAnimated(false)

		guard let organizations = navigationController.topViewController as? OrganizationsViewController else {
			completion(nil)
			return
		}

		organizations.showPersonalNotes() {
			completion(navigationController.topViewController as? OrganizationCanvasesViewController)
		}
	}
}


extension AppDelegate: UIApplicationDelegate {
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		// Crash Reporting
		SentryClient.shared = SentryClient(dsnString: config.sentryDSN)
		SentryClient.shared?.startCrashHandler()

		// Analytics
		Analytics.track(.LaunchedApp)

		// Appearance
		UIImageView.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = Color.gray

		// Defaults
		dispatch_async(dispatch_get_main_queue()) {
			NSUserDefaults.standardUserDefaults().registerDefaults([
				"PreventSleep": "WhilePluggedIn"
			])

			if let info = NSBundle.mainBundle().infoDictionary, version = info["CFBundleVersion"] as? String, shortVersion = info["CFBundleShortVersionString"] as? String {
				NSUserDefaults.standardUserDefaults().setObject("\(shortVersion) (\(version))", forKey: "HumanReadableVersion")
				NSUserDefaults.standardUserDefaults().synchronize()
			}
		}

		// Shortcut items
		application.shortcutItems = [
			UIApplicationShortcutItem(type: "shortcut-new", localizedTitle: LocalizedString.NewCanvasCommand.string, localizedSubtitle: LocalizedString.InPersonalNotes.string, icon: UIApplicationShortcutIcon(templateImageName: "New Canvas Shortcut"), userInfo: nil),
			UIApplicationShortcutItem(type: "shortcut-search", localizedTitle: LocalizedString.SearchCommand.string, localizedSubtitle: LocalizedString.InPersonalNotes.string, icon: UIApplicationShortcutIcon(type: .Search), userInfo: nil)
		]

		return true
	}

	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		showPersonalNotes() { viewController in
			guard let viewController = viewController else {
				completionHandler(false)
				return
			}

			if shortcutItem.type == "shortcut-new" {
				viewController.ready = {
					viewController.createCanvas()
				}
			} else if shortcutItem.type == "shortcut-search" {
				viewController.ready = {
					viewController.search()
				}
			}

			completionHandler(true)
		}
	}

	func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
		// For now require an account
		guard let account = AccountController.sharedController.currentAccount,
			splitViewController = (window?.rootViewController as? RootViewController)?.viewController as? SplitViewController
		else { return false }

		// Open canvas
		if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let components = userActivity.webpageURL?.pathComponents where components.count >= 4 {
			let canvasID = components[3]
			let viewController = NavigationController(rootViewController: LoadCanvasViewController(account: account, canvasID: canvasID))

			let show = {
				splitViewController.presentViewController(viewController, animated: true, completion: nil)
			}

			if splitViewController.presentedViewController != nil {
				splitViewController.presentedViewController?.dismissViewControllerAnimated(false, completion: show)
			} else {
				show()
			}
			
			return true
		}

		return false
	}
}
