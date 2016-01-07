//
//  AppDelegate.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Analytics
		Analytics.track(.LaunchedApp)

		dispatch_async(dispatch_get_main_queue()) {
			if let info = NSBundle.mainBundle().infoDictionary, version = info["CFBundleVersion"] as? String, shortVersion = info["CFBundleShortVersionString"] as? String {
				NSUserDefaults.standardUserDefaults().setObject("\(shortVersion) (\(version))", forKey: "HumanReadableVersion")
				NSUserDefaults.standardUserDefaults().synchronize()
			}
		}

		application.shortcutItems = [
			UIApplicationShortcutItem(type: "New", localizedTitle: "New Canvas", localizedSubtitle: "In Personal", icon: UIApplicationShortcutIcon(templateImageName: "New Canvas Shortcut"), userInfo: nil),
			UIApplicationShortcutItem(type: "New", localizedTitle: "Search", localizedSubtitle: "In Personal", icon: UIApplicationShortcutIcon(type: .Search), userInfo: nil)
		]

		return true
	}
}
