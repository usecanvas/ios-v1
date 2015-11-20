//
//  OrderedList.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct OrderedList: Listable {

	// MARK: - Properties

	public var delimiterRange: NSRange
	public var prefixRange: NSRange
	public var contentRange: NSRange
	public var indentation: Indentation


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (delimiterRange, indentation, prefixRange, contentRange) = parseListable(string: string, enclosingRange: enclosingRange, delimiter: "unordered-list", prefix: "1. ") else { return nil }

		self.delimiterRange = delimiterRange
		self.prefixRange = prefixRange
		self.contentRange = contentRange
		self.indentation = indentation
	}
}
