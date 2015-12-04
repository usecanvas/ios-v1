//
//  ShadowTextStorageTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/24/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class Shadow: ShadowTextStorage {
	convenience init() {
		self.init(backingText: "* Hello\n* World\nHow are you?")
	}

	override func shadowsForBackingText(backingText: String) -> [NSRange] {
		return [
			NSRange(location: 0, length: 2),
			NSRange(location: 8, length: 2)
		]
	}
}

class ShadowTextStorageTests: XCTestCase {

	let storage = Shadow()

	func testDisplayText() {
		XCTAssertEqual("Hello\nWorld\nHow are you?", storage.displayText)
	}

	func testSelection() {
		storage.backingSelection = NSRange(location: 11, length: 2)
		XCTAssertEqual(NSRange(location: 7, length: 2), storage.displaySelection)
	}

	func testDelimiterRanges() {
		var displayRange = NSRange(location: 5, length: 1)
		XCTAssertEqual(NSRange(location: 7, length: 3), storage.displayRangeToBackingRange(displayRange))

		displayRange = NSRange(location: 3, length: 16)
		XCTAssertEqual(NSRange(location: 5, length: 18), storage.displayRangeToBackingRange(displayRange))

		displayRange = NSRange(location: 0, length: 6)
		XCTAssertEqual(NSRange(location: 2, length: 8), storage.displayRangeToBackingRange(displayRange))
	}
}
