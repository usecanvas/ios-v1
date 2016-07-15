//
//  AppDelegate.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import SentrySwift
import Intercom

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties

	var window: UIWindow?
	let rootViewController = RootViewController()


	// MARK: - Private

	private func showPersonalNotes(completion: OrganizationCanvasesViewController? -> Void) {
		guard let splitViewController = rootViewController.viewController as? UISplitViewController,
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
	
	@objc private func promptForRemoteNotifications() {
		let application = UIApplication.sharedApplication()
		let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
		application.registerUserNotificationSettings(settings)
		application.registerForRemoteNotifications()
	}
	
	private func open(canvasURL canvasURL: NSURL) -> Bool {
		// For now require an account
		guard let account = AccountController.sharedController.currentAccount,
			splitViewController = (window?.rootViewController as? RootViewController)?.viewController as? SplitViewController
		else { return false }
		
		guard let components = canvasURL.pathComponents where components.count == 4 else { return false }
		
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
	
	private func verifyAccount(url url: NSURL) -> Bool {
//		guard let components = url.pathComponents where components.count == 1 && components[0] == "verify" else { return }
//		
//		guard let items = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)?.queryItems,
//			token = items.index
		return false
	}
}


extension AppDelegate: UIApplicationDelegate {
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		// Crash Reporting
		SentryClient.shared = SentryClient(dsnString: config.sentryDSN)
		SentryClient.shared?.startCrashHandler()

		// Analytics
		Analytics.track(.LaunchedApp)

		// Intercom
		Intercom.setApiKey("ios_sdk-23875f0968eab5b49e236e42b70aed9548312a77", forAppId: "zv4qksyq")
		Intercom.setPreviewPosition(.BottomRight)
		Intercom.setPreviewPaddingWithX(16, y: 16)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(promptForRemoteNotifications), name: IntercomDidStartNewConversationNotification, object: nil)

		// Appearance
		UIImageView.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = Swatch.gray

		// Defaults
		dispatch_async(dispatch_get_main_queue()) {
			NSUserDefaults.standardUserDefaults().registerDefaults([
				SleepPrevention.defaultsKey: SleepPrevention.whilePluggedIn.rawValue
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

		window?.rootViewController = rootViewController
		
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
		guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else { return false }
		
		// Open canvas
		if open(canvasURL: url) {
			return true
		}
		
		// Verify account
		if verifyAccount(url: url) {
			return true
		}
		
		// Fallback
		application.openURL(url)
		return false
	}

	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		Intercom.setDeviceToken(deviceToken)
	}

	func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
		guard url.scheme == "canvas" else { return false }

		// Login
		if url.host == "login" {
			let animated: Bool
			let viewController: OnboardingViewController

			// Already showing onboarding, scroll to the view animated
			if let vc = rootViewController.viewController as? OnboardingViewController {
				viewController = vc
				animated = true
			}

			// Not showing onboarding, show the view not animated
			else {
				// Log out first
				AccountController.sharedController.currentAccount = nil

				if let vc = rootViewController.viewController as? OnboardingViewController {
					viewController = vc
				} else {
					viewController = OnboardingViewController()
					rootViewController.viewController = viewController
				}
				
				animated = false
			}

			viewController.scrollTo(screen: .logIn, animated: animated)
			return true
		}

		return false
	}
}
