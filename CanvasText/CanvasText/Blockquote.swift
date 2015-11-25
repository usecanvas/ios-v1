//
//  Blockquote.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Blockquote: Delimitable, Prefixable {

	// MARK: - Properties

	public var delimiterRange: NSRange
	public var prefixRange: NSRange
	public var contentRange: NSRange

	public var hasAnnotation: Bool {
		return true
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (delimiterRange, prefixRange, contentRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "blockquote", prefix: "> ") else { return nil }

		self.delimiterRange = delimiterRange
		self.prefixRange = prefixRange
		self.contentRange = contentRange
	}
}
