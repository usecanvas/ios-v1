//
//  Link.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct LinkTitle {
	public var leadingDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingDelimiterRange: NSRange

	public var range: NSRange {
		return leadingDelimiterRange.union(textRange).union(trailingDelimiterRange)
	}

	public var dictionary: [String: AnyObject] {
		return [
			"leadingTitleDelimiterRange": leadingDelimiterRange,
			"titleRange": textRange,
			"trailingTitleDelimiterRange": trailingDelimiterRange
		]
	}

	public init?(match: NSTextCheckingResult) {
		leadingDelimiterRange = match.rangeAtIndex(6)
		textRange = match.rangeAtIndex(7)
		trailingDelimiterRange = match.rangeAtIndex(8)

		if leadingDelimiterRange.location == NSNotFound || textRange.location == NSNotFound || trailingDelimiterRange.location == NSNotFound {
			return nil
		}
	}
}


public struct Link: SpanNode, Foldable, NodeContainer {

	// MARK: - Properties

	public var range: NSRange
	public var leadingTextDelimiterRange: NSRange
	public var textRange: NSRange
	public var trailingTextDelimiterRange: NSRange
	public var leadingURLDelimiterRange: NSRange
	public var URLRange: NSRange
	public var title: LinkTitle?
	public var trailingURLDelimiterRange: NSRange

	public var displayRange: NSRange {
		return range
	}

	public var foldableRanges: [NSRange] {
		var ranges = [
			leadingTextDelimiterRange,
			trailingTextDelimiterRange,
			leadingURLDelimiterRange,
		]

		var URLTitle = URLRange

		if let title = title {
			URLTitle = URLTitle.union(title.range)
		}

		ranges.append(URLTitle)
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

		if let title = title {
			for (key, value) in title.dictionary {
				dictionary[key] = value
			}
		}

		return dictionary
	}

	public var subnodes = [Node]()


	// MARK: - Initializers

	public init?(match: NSTextCheckingResult) {
		if match.numberOfRanges != 10 {
			return nil
		}

		range = match.rangeAtIndex(0)
		leadingTextDelimiterRange = match.rangeAtIndex(1)
		textRange = match.rangeAtIndex(2)
		trailingTextDelimiterRange = match.rangeAtIndex(3)
		leadingURLDelimiterRange = match.rangeAtIndex(4)
		URLRange = match.rangeAtIndex(5)
		title = LinkTitle(match: match)
		trailingURLDelimiterRange = match.rangeAtIndex(9)
	}
}

