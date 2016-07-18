//
//  CanvasUITests.swift
//  CanvasUITests
//
//  Created by Sam Soffes on 7/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest

class Snapshots: XCTestCase {
	override func setUp() {
		super.setUp()
		continueAfterFailure = false

		let app = XCUIApplication()
		app.launchArguments.append("-snapshot")

		setupSnapshot(app)

		app.launch()
	}
}
