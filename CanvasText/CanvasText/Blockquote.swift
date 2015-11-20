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


	// MARK: - Initializers

	init?(string: String, enclosingRange: NSRange) {
		// TODO: Implement
		return nil
	}
}
