//
//  BlockquoteTest.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class BlockquoteTest: XCTestCase {
	func testBlockquote() {
		let node = Blockquote(string: "⧙blockquote⧘> Hello", enclosingRange: NSRange(location: 0, length: 19))!
		XCTAssertEqual(NSRange(location: 0, length: 12), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 12, length: 2), node.prefixRange)
		XCTAssertEqual(NSRange(location: 14, length: 5), node.contentRange)
	}
}
