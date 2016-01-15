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
		XCTAssertEqual(NSRange(location: 0, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.displayRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
		XCTAssertEqual(Checklist.Completion.Incomplete, node.completion)
	}

	func testCompleted() {
		let node = Checklist(string: "⧙checklist-1⧘- [x] Done", enclosingRange: NSRange(location: 10, length: 23))!
		XCTAssertEqual(NSRange(location: 10, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 29, length: 4), node.displayRange)
		XCTAssertEqual(Indentation.One, node.indentation)
		XCTAssertEqual(Checklist.Completion.Complete, node.completion)
	}

	func testUnordered() {
		let node = UnorderedList(string: "⧙unordered-list-0⧘- Hello", enclosingRange: NSRange(location: 0, length: 25))!
		XCTAssertEqual(NSRange(location: 0, length: 20), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 20, length: 5), node.displayRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
	}

	func testOrdered() {
		let node = OrderedList(string: "⧙ordered-list-0⧘1. Hello", enclosingRange: NSRange(location: 0, length: 24))!
		XCTAssertEqual(NSRange(location: 0, length: 19), node.nativePrefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), node.displayRange)
		XCTAssertEqual(Indentation.Zero, node.indentation)
	}
}
