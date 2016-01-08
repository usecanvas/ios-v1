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

	// MARK: - Tests

	func testDoubleEmphasis() {
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

	func testEmphasis() {
		let markdown = "Hello *world*."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 14), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			Emphasis(
				leadingDelimiterRange: NSRange(location: 6, length: 1),
				textRange: NSRange(location: 7, length: 5),
				trailingDelimiterRange: NSRange(location: 12, length: 1),
				subnodes: [
					Text(range: NSRange(location: 7, length: 5))
				]
			),
			Text(range: NSRange(location: 13, length: 1))
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}

	func testMixed1() {
		let markdown = "Hello *big* **world**."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 22), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			Emphasis(
				leadingDelimiterRange: NSRange(location: 6, length: 1),
				textRange: NSRange(location: 7, length: 3),
				trailingDelimiterRange: NSRange(location: 10, length: 1),
				subnodes: [
					Text(range: NSRange(location: 7, length: 3))
				]
			),
			Text(range: NSRange(location: 11, length: 1)),
			DoubleEmphasis(
				leadingDelimiterRange: NSRange(location: 12, length: 2),
				textRange: NSRange(location: 14, length: 5),
				trailingDelimiterRange: NSRange(location: 19, length: 2),
				subnodes: [
					Text(range: NSRange(location: 14, length: 5))
				]
			),
			Text(range: NSRange(location: 21, length: 1)),
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}

	func testMixed2() {
		let markdown = "Hello **big** *world*."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 22), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			DoubleEmphasis(
				leadingDelimiterRange: NSRange(location: 6, length: 2),
				textRange: NSRange(location: 8, length: 3),
				trailingDelimiterRange: NSRange(location: 11, length: 2),
				subnodes: [
					Text(range: NSRange(location: 8, length: 3))
				]
			),
			Text(range: NSRange(location: 13, length: 1)),
			Emphasis(
				leadingDelimiterRange: NSRange(location: 14, length: 1),
				textRange: NSRange(location: 15, length: 5),
				trailingDelimiterRange: NSRange(location: 20, length: 1),
				subnodes: [
					Text(range: NSRange(location: 15, length: 5))
				]
			),
			Text(range: NSRange(location: 21, length: 1)),
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}


	// MARK: - Private

	private func parse(markdown: String) -> [[String: AnyObject]] {
		return Parser(string: markdown).parse().nodes.map { $0.dictionary }
	}
}
