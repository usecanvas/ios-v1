//
//  Blockquote.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Blockquote: NativePrefixable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var contentRange: NSRange

	public var hasAnnotation: Bool {
		return true
	}


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (nativePrefixRange, prefixRange, contentRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "blockquote", prefix: "> ") else { return nil }

		range = enclosingRange
		self.nativePrefixRange = nativePrefixRange.union(prefixRange)
		self.contentRange = contentRange
	}
}
