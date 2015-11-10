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
		let controller = TextController(text: "⧙doc-heading⧘A Lovely Document\nThis is a paragraph.\n⧙blockquote⧘> Here’s to the crazy ones…")
		let start = controller.text.startIndex
		
//		XCTAssertEqual(controller.lines, [
//			Line(kind: .DocHeading, delimiter: start...start.advancedBy(12), content: start.advancedBy(13)...start.advancedBy(29)),
//			Annotation(block: .Blockquote, delimiter: start.advancedBy(52)...start.advancedBy(64), content: start.advancedBy(64)...start.advancedBy(70))
//		])
		
		XCTAssertEqual("A Lovely Document\nThis is a paragraph.\n> Here’s to the crazy ones…", controller.displayText)
		
		
	}
    
}
