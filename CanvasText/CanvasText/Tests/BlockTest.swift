//
//  BlockTest.swift
//  CanvasTextTests
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class BlockTest: XCTestCase {
//	func testDocHeading() {
//		let controller = TextController(backingText: "⧙doc-heading⧘A Lovely Document")
//		
//		XCTAssertEqual([
//			Block(kind: .DocHeading, delimiterRange: NSRange(location: 0, length: 13), contentRange: NSRange(location: 13, length: 17))
//		], controller.blocks)
//		
//		XCTAssertEqual("A Lovely Document", controller.displayText)
//	}
//
//	func testBlockquote() {
//		let controller = TextController(backingText: "⧙doc-heading⧘A Lovely Document\nThis is a paragraph.\n⧙blockquote⧘> Here’s to the crazy ones…")
//
//		XCTAssertEqual([
//			Block(kind: .DocHeading, delimiterRange: NSRange(location: 0, length: 13), contentRange: NSRange(location: 13, length: 17)),
//			Block(kind: .Paragraph, contentRange: NSRange(location: 31, length: 20)),
//			Block(kind: .Blockquote, delimiterRange: NSRange(location: 52, length: 12), prefixRange: NSRange(location: 64, length: 2), contentRange: NSRange(location: 66, length: 25))
//		], controller.blocks)
//
//		XCTAssertEqual("A Lovely Document\nThis is a paragraph.\nHere’s to the crazy ones…", controller.displayText)
//	}
//
//	func testHeading() {
//		let controller = TextController(backingText: "# Help, I need somebody\n## Help, not just anybody\n### Help, you know I need someone\n#### Help!\n##### When I was younger, so much younger than today\n###### I never needed anybody's help in any way")
//
//		XCTAssertEqual([
//			Block(kind: .Heading1, prefixRange: NSRange(location: 0, length: 2), contentRange: NSRange(location: 2, length: 21)),
//			Block(kind: .Heading2, prefixRange: NSRange(location: 24, length: 3), contentRange: NSRange(location: 27, length: 22)),
//			Block(kind: .Heading3, prefixRange: NSRange(location: 50, length: 4), contentRange: NSRange(location: 54, length: 29)),
//			Block(kind: .Heading4, prefixRange: NSRange(location: 84, length: 5), contentRange: NSRange(location: 89, length: 5)),
//			Block(kind: .Heading5, prefixRange: NSRange(location: 95, length: 6), contentRange: NSRange(location: 101, length: 46)),
//			Block(kind: .Heading6, prefixRange: NSRange(location: 148, length: 7), contentRange: NSRange(location: 155, length: 40))
//		], controller.blocks)
//
//		XCTAssertEqual("Help, I need somebody\nHelp, not just anybody\nHelp, you know I need someone\nHelp!\nWhen I was younger, so much younger than today\nI never needed anybody's help in any way", controller.displayText)
//	}
//
//	func testUnorderedList() {
//		let controller = TextController(backingText: "⧙unordered-list-0⧘- Hello\n⧙unordered-list-0⧘- World")
//
//		XCTAssertEqual([
//			Block(kind: .UnorderedList, delimiterRange: NSRange(location: 0, length: 18), prefixRange: NSRange(location: 18, length: 2), contentRange: NSRange(location: 20, length: 5)),
//			Block(kind: .UnorderedList, delimiterRange: NSRange(location: 26, length: 18), prefixRange: NSRange(location: 44, length: 2), contentRange: NSRange(location: 46, length: 5))
//		], controller.blocks)
//
//		XCTAssertEqual("Hello\nWorld", controller.displayText)
//	}
//
//	func testOrderedList() {
//		let controller = TextController(backingText: "⧙ordered-list-0⧘1. Hello\n⧙ordered-list-0⧘1. World")
//
//		XCTAssertEqual([
//			Block(kind: .OrderedList, delimiterRange: NSRange(location: 0, length: 16), prefixRange: NSRange(location: 16, length: 3), contentRange: NSRange(location: 19, length: 5)),
//			Block(kind: .OrderedList, delimiterRange: NSRange(location: 25, length: 16), prefixRange: NSRange(location: 41, length: 3), contentRange: NSRange(location: 44, length: 5))
//		], controller.blocks)
//
//		XCTAssertEqual("Hello\nWorld", controller.displayText)
//	}
//
//	func testChecklist() {
//		let controller = TextController(backingText: "⧙checklist-0⧘- [ ] Done\n⧙checklist-0⧘- [ ] Not done")
//
//		XCTAssertEqual([
//			Block(kind: .Checklist, delimiterRange: NSRange(location: 0, length: 13), prefixRange: NSRange(location: 13, length: 6), contentRange: NSRange(location: 19, length: 4)),
//			Block(kind: .Checklist, delimiterRange: NSRange(location: 24, length: 13), prefixRange: NSRange(location: 37, length: 6), contentRange: NSRange(location: 43, length: 8))
//		], controller.blocks)
//
//		XCTAssertEqual("Done\nNot done", controller.displayText)
//	}
//
//	func testCodeBlock() {
//		let controller = TextController(backingText: "⧙code⧘puts \"hi\"")
//
//		XCTAssertEqual([
//			Block(kind: .Code, delimiterRange: NSRange(location: 0, length: 6), contentRange: NSRange(location: 6, length: 9))
//		], controller.blocks)
//
//		XCTAssertEqual("puts \"hi\"", controller.displayText)
//	}
}
