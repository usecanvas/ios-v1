//
//  FoldingLayoutManagerTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/22/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
@testable import CanvasText

class FoldingLayoutManagerTests: XCTestCase {
	func testProperties() {
		let textStorage = NSTextStorage()
		let layoutManager = FoldingLayoutManager()
		let textContainer = NSTextContainer(size: CGSize(width: 480, height: 640))
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		textStorage.beginEditing()
		textStorage.replaceCharactersInRange(.zero, withString: "This is **bold**.")
		textStorage.setAttributes([FoldableAttributeName: true], range: NSRange(location: 8, length: 2))
		textStorage.setAttributes([FoldableAttributeName: true], range: NSRange(location: 14, length: 2))
		textStorage.endEditing()

		XCTAssertEqual(NSGlyphProperty.ControlCharacter, layoutManager.propertyForGlyphAtIndex(8))
		XCTAssertEqual(NSGlyphProperty.ControlCharacter, layoutManager.propertyForGlyphAtIndex(9))
		XCTAssertNotEqual(NSGlyphProperty.ControlCharacter, layoutManager.propertyForGlyphAtIndex(10))
		XCTAssertEqual(NSGlyphProperty.ControlCharacter, layoutManager.propertyForGlyphAtIndex(14))
		XCTAssertEqual(NSGlyphProperty.ControlCharacter, layoutManager.propertyForGlyphAtIndex(15))
	}
}
