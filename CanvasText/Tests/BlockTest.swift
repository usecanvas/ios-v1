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
	func testDocHeading() {
		let controller = TextController(backingText: "⧙doc-heading⧘A Lovely Document")
		
		XCTAssertEqual([
			Line(kind: .DocHeading, delimiterRange: NSRange(location: 0, length: 13), contentRange: NSRange(location: 13, length: 17))
		], controller.lines)
		
		XCTAssertEqual("A Lovely Document", controller.displayText)
	}

	func testBlockquote() {
		let controller = TextController(backingText: "⧙doc-heading⧘A Lovely Document\nThis is a paragraph.\n⧙blockquote⧘> Here’s to the crazy ones…")

		XCTAssertEqual([
			Line(kind: .DocHeading, delimiterRange: NSRange(location: 0, length: 13), contentRange: NSRange(location: 13, length: 17)),
			Line(kind: .Paragraph, contentRange: NSRange(location: 31, length: 20)),
			Line(kind: .Blockquote, delimiterRange: NSRange(location: 52, length: 12), prefixRange: NSRange(location: 64, length: 2), contentRange: NSRange(location: 66, length: 25))
		], controller.lines)

		XCTAssertEqual("A Lovely Document\nThis is a paragraph.\nHere’s to the crazy ones…", controller.displayText)
	}

	func testHeading() {
		let controller = TextController(backingText: "# Help, I need somebody\n## Help, not just anybody\n### Help, you know I need someone\n#### Help!\n##### When I was younger, so much younger than today\n###### I never needed anybody's help in any way")

		XCTAssertEqual([
			Line(kind: .Heading1, prefixRange: NSRange(location: 0, length: 2), contentRange: NSRange(location: 2, length: 21)),
			Line(kind: .Heading2, prefixRange: NSRange(location: 24, length: 3), contentRange: NSRange(location: 27, length: 22)),
			Line(kind: .Heading3, prefixRange: NSRange(location: 50, length: 4), contentRange: NSRange(location: 54, length: 29)),
			Line(kind: .Heading4, prefixRange: NSRange(location: 84, length: 5), contentRange: NSRange(location: 89, length: 5)),
			Line(kind: .Heading5, prefixRange: NSRange(location: 95, length: 6), contentRange: NSRange(location: 101, length: 46)),
			Line(kind: .Heading6, prefixRange: NSRange(location: 148, length: 7), contentRange: NSRange(location: 155, length: 40))
		], controller.lines)

		XCTAssertEqual("Help, I need somebody\nHelp, not just anybody\nHelp, you know I need someone\nHelp!\nWhen I was younger, so much younger than today\nI never needed anybody's help in any way", controller.displayText)
	}
}
