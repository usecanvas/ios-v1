//
//  DoubleEmphasis.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct DoubleEmphasis: ContainerNode {

	public var range: NSRange

	public var contentRange: NSRange {
		return range
	}

	public var dictionary: [String: AnyObject] {
		return [
			"type": "double-emphasis",
			"range": range.dictionary,
			"contentRange": contentRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]
	}

	public var subnodes: [Node]

	public init?(string: String, enclosingRange: NSRange) {
		return nil
	}

	public init(range: NSRange, subnodes: [Node]) {
		self.range = range
		self.subnodes = subnodes
	}
}
