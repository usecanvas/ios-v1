//
//  CanvasUITests.swift
//  CanvasUITests
//
//  Created by Sam Soffes on 7/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest

class CanvasUITests: XCTestCase {
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		XCUIApplication().launch()
	}
}
