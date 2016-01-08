//
//  SpanLevelTests.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasText

class SpanLevelTests: XCTestCase {
	func testBasics() {
		let markdown = "Hello **world**."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 16), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			DoubleEmphasis(
				leadingDelimiterRange: NSRange(location: 6, length: 2),
				textRange: NSRange(location: 8, length: 5),
				trailingDelimiterRange: NSRange(location: 13, length: 2),
				subnodes: [
					Text(range: NSRange(location: 8, length: 5))
				]
			),
			Text(range: NSRange(location: 15, length: 1))
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}

	private func parse(markdown: String) -> [[String: AnyObject]] {
		return Parser(string: markdown).parse().nodes.map { $0.dictionary }
	}
}
