//
//  Paragraph.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Paragraph: Node {

	// MARK: - Properties

	public var range: NSRange
	public var contentRange: NSRange
	public let allowsReturnCompletion = false


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		// Prevent any Canvas Native from appearing in the documment
		if string.hasPrefix(leadingDelimiter) {
			return nil
		}

		range = enclosingRange
		self.contentRange = enclosingRange
	}
}
