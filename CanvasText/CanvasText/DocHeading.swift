//
//  DocHeading.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

public struct DocHeading: Delimitable {

	// MARK: - Properties

	public var delimiterRange: NSRange
	public var contentRange: NSRange


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (delimiterRange, contentRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "doc-heading") else { return nil }

		self.delimiterRange = delimiterRange
		self.contentRange = contentRange
	}
}
