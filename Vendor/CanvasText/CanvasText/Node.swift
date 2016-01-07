//
//  Node.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Node {

	/// Range of the entire node
	var range: NSRange { get }

	/// Range of the text content
	var contentRange: NSRange { get }

	init?(string: String, enclosingRange: NSRange)

	func contentInString(string: String) -> String
}


extension Node {
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(contentRange)
	}
}
