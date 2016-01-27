//
//  Text.swift
//  CanvasNative
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Text: Node {

	// MARK: - Properties

	public var range: NSRange

	public var displayRange: NSRange {
		return range
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "text",
			"range": range.dictionary,
			"displayRange": displayRange.dictionary
		]
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		range = enclosingRange
	}

	public init(range: NSRange) {
		self.range = range
	}
}
