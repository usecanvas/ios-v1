//
//  Link.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Link: SpanNode, Foldable, NodeContainer {

	// MARK: - Properties

	public var range: NSRange
	public var leadingTextDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingTextDelimiterRange: NSRange
	public var leadingURLDelimiterRange: NSRange
	public var URLRange: NSRange
	public var titleRange: NSRange?
	public var trailingURLDelimiterRange: NSRange

	public var displayRange: NSRange {
		return range
	}

	public var foldableRanges: [NSRange] {
		var ranges = [
			leadingTextDelimiterRange,
			trailingTextDelimiterRange,
			leadingURLDelimiterRange,
			URLRange
		]

		if let titleRange = titleRange {
			ranges.append(titleRange)
		}

		ranges.append(trailingURLDelimiterRange)

		return ranges
	}

	public var dictionary: [String: AnyObject] {
		var dictionary: [String: AnyObject] = [
			"type": "link",
			"range": range.dictionary,
			"displayRange": displayRange.dictionary,
			"leadingTextDelimiterRange": leadingTextDelimiterRange.dictionary,
			"textRange": textRange.dictionary,
			"trailingTextDelimiterRange": trailingTextDelimiterRange.dictionary,
			"leadingURLDelimiterRange": leadingURLDelimiterRange.dictionary,
			"URLRange": URLRange.dictionary,
			"trailingURLDelimiterRange": trailingURLDelimiterRange.dictionary,
			"subnodes": subnodes.map { $0.dictionary }
		]

		if let titleRange = titleRange {
			dictionary["titleRange"] = titleRange.dictionary
		}

		return dictionary
	}

	public var subnodes = [Node]()


	// MARK: - Initializers

	public init(range: NSRange, leadingTextDelimiterRange: NSRange, textRange: NSRange, trailingTextDelimiterRange: NSRange, leadingURLDelimiterRange: NSRange, URLRange: NSRange, titleRange: NSRange? = nil, trailingURLDelimiterRange: NSRange, subnodes: [Node] = []) {
		self.range = range
		self.leadingTextDelimiterRange = leadingTextDelimiterRange
		self.textRange = textRange
		self.trailingTextDelimiterRange = trailingTextDelimiterRange
		self.leadingURLDelimiterRange = leadingURLDelimiterRange
		self.URLRange = URLRange
		self.titleRange = titleRange
		self.trailingURLDelimiterRange = trailingURLDelimiterRange
		self.subnodes = subnodes
	}

	public init?(match: NSTextCheckingResult) {
		if match.numberOfRanges != 8 {
			return nil
		}

		range = match.rangeAtIndex(0)
		leadingTextDelimiterRange = match.rangeAtIndex(1)
		textRange = match.rangeAtIndex(2)
		trailingTextDelimiterRange = match.rangeAtIndex(3)
		leadingURLDelimiterRange = match.rangeAtIndex(4)
		URLRange = match.rangeAtIndex(5)
		trailingURLDelimiterRange = match.rangeAtIndex(7)

		let titleRange = match.rangeAtIndex(6)
		if titleRange.location == NSNotFound {
			self.titleRange = nil
		} else {
			self.titleRange = titleRange
		}
	}
}

