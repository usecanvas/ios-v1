//
//  Title.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct Title: NativePrefixable, Equatable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var contentRange: NSRange

	public let allowsReturnCompletion = false


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (nativePrefixRange, contentRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "doc-heading") else { return nil }

		range = enclosingRange
		self.nativePrefixRange = nativePrefixRange
		self.contentRange = contentRange
	}

	public init(nativePrefixRange: NSRange, contentRange: NSRange) {
		range = nativePrefixRange.union(contentRange)
		self.nativePrefixRange = nativePrefixRange
		self.contentRange = contentRange
	}
}


public func ==(lhs: Title, rhs: Title) -> Bool {
	return lhs.nativePrefixRange == rhs.nativePrefixRange && lhs.contentRange == rhs.contentRange
}
