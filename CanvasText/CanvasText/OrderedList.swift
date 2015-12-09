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
	public var indentationRange: NSRange
	public var indentation: Indentation

	public var hasAnnotation: Bool {
		return true
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (delimiterRange, indentationRange, indentation, prefixRange, contentRange) = parseListable(string: string, enclosingRange: enclosingRange, delimiter: "ordered-list", prefix: "1. ") else { return nil }

		self.delimiterRange = delimiterRange
		self.prefixRange = prefixRange
		self.contentRange = contentRange
		self.indentationRange = indentationRange
		self.indentation = indentation
	}


	// MARK: - Native

	public static func nativeRepresentation(indentation: Indentation = .Zero) -> String {
		return "\(leadingDelimiter)ordered-\(indentation.string)\(trailingDelimiter)- "
	}
}
