//
//  GhostTextStorageTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/24/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class Ghost: GhostTextStorage {
	convenience init() {
		self.init(backingText: "<p>Hello</p>\n<p>World</p>")
	}

	override func hiddenRangesForBackingText(backingText: String) -> [NSRange] {
		return [
			NSRange(location: 0, length: 3),
			NSRange(location: 8, length: 4),
			NSRange(location: 13, length: 3),
			NSRange(location: 21, length: 4)
		]
	}
}

class GhostTextStorageTests: XCTestCase {

	let storage = Ghost()

	func testDisplayText() {
		XCTAssertEqual("Hello\nWorld", storage.displayText)
	}
}
