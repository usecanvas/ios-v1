//
//  TickingLabel.swift
//  Canvas
//
//  Created by Sam Soffes on 1/28/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class TickingLabel: UILabel {

	// MARK: - Properties

	var date: NSDate? {
		didSet {
			tick()
		}
	}

	private static var timer: NSTimer?
	private static let tickNotificationName = "TickingLabel.tickNotification"
	private static var setupToken: dispatch_once_t = 0


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "tick", name: self.dynamicType.tickNotificationName, object: nil)

		dispatch_once(&self.dynamicType.setupToken) {
			self.dynamicType.setupTimer()
		}
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - Private

	private class func setupTimer() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
		applicationDidBecomeActive()
	}

	@objc private class func fire() {
		NSNotificationCenter.defaultCenter().postNotificationName(tickNotificationName, object: nil)
	}

	@objc private class func applicationWillResignActive() {
		timer?.invalidate()
		timer = nil
	}

	@objc private class func applicationDidBecomeActive() {
		let timer = NSTimer(timeInterval: 1, target: self, selector: "fire", userInfo: nil, repeats: true)
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
		timer.fire()
		self.timer = timer
	}

	@objc private func tick() {
		text = date?.briefTimeAgoInWords
	}
}
