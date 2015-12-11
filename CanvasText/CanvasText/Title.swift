//
//  Title.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Title: Delimitable, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var delimiterRange: NSRange
	public var contentRange: NSRange

	public let allowsReturnCompletion = false


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (delimiterRange, contentRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "doc-heading") else { return nil }

		range = enclosingRange
		self.delimiterRange = delimiterRange
		self.contentRange = contentRange
	}
}


public func ==(lhs: Title, rhs: Title) -> Bool {
	return lhs.delimiterRange == rhs.delimiterRange && lhs.contentRange == rhs.contentRange
}
