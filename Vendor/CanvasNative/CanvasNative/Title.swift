//
//  Title.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Title: NativePrefixable {

	// MARK: - Properties

	public var range: NSRange
	public var nativePrefixRange: NSRange
	public var displayRange: NSRange

	public let allowsReturnCompletion = false


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		guard let (nativePrefixRange, displayRange) = parseBlockNode(string: string, enclosingRange: enclosingRange, delimiter: "doc-heading") else { return nil }

		range = enclosingRange
		self.nativePrefixRange = nativePrefixRange
		self.displayRange = displayRange
	}

	public init(nativePrefixRange: NSRange, displayRange: NSRange) {
		range = nativePrefixRange.union(displayRange)
		self.nativePrefixRange = nativePrefixRange
		self.displayRange = displayRange
	}


	// MARK: - Native

	public static func nativeRepresentation(string: String? = nil) -> String {
		return "\(leadingNativePrefix)doc-heading\(trailingNativePrefix)" + (string ?? "")
	}
}
