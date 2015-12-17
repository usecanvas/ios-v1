//
//  ListableTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class ListableTests: XCTestCase {
	func testUncompleted() {
		let node = Checklist(string: "⧙checklist-0⧘- [ ] Hello", enclosingRange: NSRange(location: 0, length: 24))!
		XCTAssertEqual(NSRange(location: 0, length: 13), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 13, length: 6), node.prefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.contentRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
		XCTAssertEqual(Checklist.Completion.Incomplete, node.completion)
	}

	func testCompleted() {
		let node = Checklist(string: "⧙checklist-1⧘- [x] Done", enclosingRange: NSRange(location: 10, length: 23))!
		XCTAssertEqual(NSRange(location: 10, length: 13), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 23, length: 6), node.prefixRange)
		XCTAssertEqual(NSRange(location: 29, length: 4), node.contentRange)
		XCTAssertEqual(Indentation.One, node.indentation)
		XCTAssertEqual(Checklist.Completion.Complete, node.completion)
	}

	func testUnordered() {
		let node = UnorderedList(string: "⧙unordered-list-0⧘- Hello", enclosingRange: NSRange(location: 0, length: 25))!
		XCTAssertEqual(NSRange(location: 0, length: 18), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 18, length: 2), node.prefixRange)
		XCTAssertEqual(NSRange(location: 20, length: 5), node.contentRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
	}

	func testOrdered() {
		let node = OrderedList(string: "⧙ordered-list-0⧘1. Hello", enclosingRange: NSRange(location: 0, length: 24))!
		XCTAssertEqual(NSRange(location: 0, length: 16), node.delimiterRange)
		XCTAssertEqual(NSRange(location: 16, length: 3), node.prefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.contentRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
	}
}
