//
//  SpanLevelTests.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import XCTest
import CanvasNative

class SpanLevelTests: XCTestCase {

	// MARK: - Tests

	func testCodeSpan1() {
		let markdown = "Hello `world`."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 14), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			CodeSpan(
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

	func testCodeSpan2() {
		let markdown = "Hello ``world``."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 16), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			CodeSpan(
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

	func testLink() {
		let markdown = "Hello [world](http://example.com)."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 34), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			Link(
				range: NSRange(location: 6, length: 27),
				leadingTextDelimiterRange: NSRange(location: 6, length: 1),
				textRange: NSRange(location: 7, length: 5),
				trailingTextDelimiterRange: NSRange(location: 12, length: 1),
				leadingURLDelimiterRange: NSRange(location: 13, length: 1),
				URLRange: NSRange(location: 14, length: 18),
				trailingURLDelimiterRange: NSRange(location: 32, length: 1),
				subnodes: [
					Text(range: NSRange(location: 7, length: 5))
				]
			),
			Text(range: NSRange(location: 33, length: 1))
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}

	func testLinkWithTitle() {
		let markdown = "Hello [world](http://example.com \"Example\")."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 44), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			Link(
				range: NSRange(location: 6, length: 37),
				leadingTextDelimiterRange: NSRange(location: 6, length: 1),
				textRange: NSRange(location: 7, length: 5),
				trailingTextDelimiterRange: NSRange(location: 12, length: 1),
				leadingURLDelimiterRange: NSRange(location: 13, length: 1),
				URLRange: NSRange(location: 14, length: 18),
				title: LinkTitle(
					leadingDelimiterRange:  NSRange(location: 33, length: 1),
					textRange:  NSRange(location: 34, length: 7),
					trailingDelimiterRange:  NSRange(location: 41, length: 1)
				),
				trailingURLDelimiterRange: NSRange(location: 42, length: 1),
				subnodes: [
					Text(range: NSRange(location: 7, length: 5))
				]
			),
			Text(range: NSRange(location: 43, length: 1))
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}

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

	func testNested() {
		let markdown = "Hello ***world***."

		let paragraph = Paragraph(range: NSRange(location: 0, length: 18), subnodes: [
			Text(range: NSRange(location: 0, length: 6)),
			DoubleEmphasis(
				leadingDelimiterRange: NSRange(location: 6, length: 2),
				textRange: NSRange(location: 8, length: 7),
				trailingDelimiterRange: NSRange(location: 15, length: 2),
				subnodes: [
					Emphasis(
						leadingDelimiterRange: NSRange(location: 8, length: 1),
						textRange: NSRange(location: 9, length: 5),
						trailingDelimiterRange: NSRange(location: 14, length: 1),
						subnodes: [
							Text(range: NSRange(location: 9, length: 5))
						]
					)
				]
			),
			Text(range: NSRange(location: 17, length: 1))
		])

		XCTAssertEqual([paragraph].map { $0.dictionary }, parse(markdown))
	}


	// MARK: - Private

	private func parse(markdown: String) -> [[String: AnyObject]] {
		return Parser(string: markdown).parse().map { $0.dictionary }
	}
}
