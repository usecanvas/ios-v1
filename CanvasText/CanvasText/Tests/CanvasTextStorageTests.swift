//
//  CanvasTextStorageTests.swift
//  CanvasTextTests
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

struct TestTheme: Theme {
	let fontSize: CGFloat = 16
	let backgroundColor = Color.whiteColor()
	let foregroundColor = Color.blackColor()
	let lineHeightMultiple: CGFloat = 1.2

	func attributesForNode(node: Node, nextSibling: Node?, horizontalSizeClass: UserInterfaceSizeClass) -> Attributes {
		return [:]
	}
}


class CanvasTextStorageTests: XCTestCase {
	let storage = CanvasTextStorage(theme: TestTheme())

	func testTitle() {
		storage.backingText = "⧙doc-heading⧘A Lovely Document"

		let node = Title(delimiterRange: NSRange(location: 0, length: 13), contentRange: NSRange(location: 13, length: 17))
		XCTAssertEqual(node, (storage.nodes.first as! Title))
		
		XCTAssertEqual("A Lovely Document", storage.displayText)
	}

	func testUnsupported() {
		storage.backingText = "Hello\n⧙nonsense⧘A Lovely Document\nWorld"

		XCTAssertEqual(2, storage.nodes.count)
		XCTAssertEqual("Hello\nWorld", storage.displayText)
	}
}
