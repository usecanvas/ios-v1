//
//  CodeBlock.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct CodeBlock: NativePrefixable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange

	public let hasAnnotation = true


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (nativePrefixRange, displayRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "code") else { return nil }

		range = enclosingRange
		self.nativePrefixRange = nativePrefixRange
		self.displayRange = displayRange
	}
}
