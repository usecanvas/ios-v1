//
//  Paragraph.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Paragraph: BlockNode, NodeContainer {

	// MARK: - Properties

	public var range: NSRange

	public var displayRange: NSRange {
		return range
	}

	public var textRange: NSRange {
		return range
	}

	public var subnodes = [Node]()

	public var dictionary: [String: AnyObject] {
		return [
			"type": "paragraph",
			"range": range.dictionary,
			"displayRange": displayRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}

	public let allowsReturnCompletion = false


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		// Prevent any Canvas Native from appearing in the documment
		if string.hasPrefix(leadingNativePrefix) {
			return nil
		}

		range = enclosingRange
	}

	public init(range: NSRange, subnodes: [Node]) {
		self.range = range
		self.subnodes = subnodes
	}
}
