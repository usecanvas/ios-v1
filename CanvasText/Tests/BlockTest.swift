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
		let controller = TextController(backingText: "⧙doc-heading⧘A Lovely Document\nThis is a paragraph.\n⧙blockquote⧘> Here’s to the crazy ones…")
		
		XCTAssertEqual(controller.lines, [
			Line(kind: .DocHeading, delimiter: NSRange(location: 0, length: 13), content: NSRange(location: 13, length: 17)),
			Line(kind: .Paragraph, content: NSRange(location: 31, length: 20)),
			Line(kind: .Blockquote, delimiter: NSRange(location: 52, length: 12), content: NSRange(location: 64, length: 27))
		])
		
		XCTAssertEqual("A Lovely Document\nThis is a paragraph.\n> Here’s to the crazy ones…", controller.displayText)		
	}
    
}
