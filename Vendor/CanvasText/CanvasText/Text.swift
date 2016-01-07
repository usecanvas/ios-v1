//
//  Text.swift
//  CanvasText
//
//  Created by Sam Soffes on 1/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

public struct Text: Node {

	// MARK: - Properties

	public var range: NSRange {
		return contentRange
	}

	public var contentRange: NSRange


	// MARK: - Initializers

	public init?(string: String, enclosingRange: NSRange) {
		contentRange = enclosingRange
	}
}
