//
//  Node.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

let leadingDelimiter = "⧙"
let trailingDelimiter = "⧘"


public protocol Node {

	// MARK: - Properties

	var delimiterRange: NSRange? { get }
	var prefixRange: NSRange? { get }
	var contentRange: NSRange { get }


	// MARK: - Initializers

	init?(string: String, enclosingRange: NSRange)


	// MARK: - Functions

	func contentInString(string: String) -> String
}


extension Node {
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(contentRange)
	}
}


public enum Indentation: UInt {
	case Zero = 0
	case One = 1
	case Two = 2
	case Three = 3
}


public protocol ListItem: Node {
	var indentation: Indentation { get }
}
