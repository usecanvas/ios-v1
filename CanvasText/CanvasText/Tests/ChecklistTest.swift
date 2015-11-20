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
		let task = Checklist(string: "⧙checklist-0⧘- [ ] Hello", enclosingRange: NSRange(location: 0, length: 24))!
		XCTAssertEqual(NSRange(location: 0, length: 13), task.delimiterRange)
		XCTAssertEqual(NSRange(location: 13, length: 6), task.prefixRange)
		XCTAssertEqual(NSRange(location: 19, length: 5), task.contentRange)
		XCTAssertEqual(Indentation.Zero, task.indentation)
		XCTAssert(!task.completed)
	}

	func testCompleted() {
		let task = Checklist(string: "⧙checklist-1⧘- [x] Done", enclosingRange: NSRange(location: 10, length: 23))!
		XCTAssertEqual(NSRange(location: 10, length: 13), task.delimiterRange)
		XCTAssertEqual(NSRange(location: 23, length: 6), task.prefixRange)
		XCTAssertEqual(NSRange(location: 29, length: 4), task.contentRange)
		XCTAssertEqual(Indentation.One, task.indentation)
		XCTAssert(task.completed)
	}
}
