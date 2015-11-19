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

	public let delimiterRange: NSRange? = nil
	public let prefixRange: NSRange? = nil
	public var contentRange: NSRange


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		self.contentRange = enclosingRange
	}
}
