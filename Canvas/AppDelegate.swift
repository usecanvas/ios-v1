//
//  AppDelegate.swift
//  Canvas
//
//  Created by Sam Soffes on 11/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

let baseURL = NSURL(string: "https://api.usecanvas.com/")!
let realtimeURL = NSURL(string: "wss://api.usecanvas.com/realtime")!
let longhouseURL = NSURL(string: "wss://presence.usecanvas.com/")!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow? = {
		let window = UIWindow()
		window.tintColor = Color.brand
		window.rootViewController = RootViewController()
		return window
	}()


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

		UINavigationBar.appearance().barTintColor = Color.white

		window?.makeKeyAndVisible()
		return true
	}
}
