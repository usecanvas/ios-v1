//
//  ChecklistTest.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class ChecklistTest: XCTestCase {
	func testUncompleted() {
		let node = Checklist(string: "⧙checklist-0⧘- [ ] Hello", enclosingRange: NSRange(location: 0, length: 24))!
		XCTAssertEqual(NSRange(location: 0, length: 13), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 13, length: 6), node.prefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.contentRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
		XCTAssert(!node.completed)
	}

	func testCompleted() {
		let node = Checklist(string: "⧙checklist-1⧘- [x] Done", enclosingRange: NSRange(location: 10, length: 23))!
		XCTAssertEqual(NSRange(location: 10, length: 13), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 23, length: 6), node.prefixRange)
		XCTAssertEqual(NSRange(location: 29, length: 4), node.contentRange)
		XCTAssertEqual(Indentation.One, node.indentation)
		XCTAssert(node.completed)
	}
}
