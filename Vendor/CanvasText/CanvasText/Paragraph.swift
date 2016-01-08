//
//  Paragraph.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Paragraph: BlockNode, ContainerNode {

	// MARK: - Properties

	public var range: NSRange

	public var contentRange: NSRange {
		return range
	}

	public var subnodes: [Node]

	public var dictionary: [String: AnyObject] {
		return [
			"type": "paragraph",
			"range": range.dictionary,
			"contentRange": contentRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}

	public let allowsReturnCompletion = false


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		// Prevent any Canvas Native from appearing in the documment
		if string.hasPrefix(leadingDelimiter) {
			return nil
		}

		range = enclosingRange
		subnodes = parseSpanLevelNodes(string: string, enclosingRange: enclosingRange)
	}

	public init(range: NSRange, subnodes: [Node]) {
		self.range = range
		self.subnodes = subnodes
	}
}
