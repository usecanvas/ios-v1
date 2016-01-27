//
//  Node.swift
//  CanvasNative
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Node {

	/// Range of the entire node in the backing text
	var range: NSRange { get }

	/// Range of the node in the display text
	var displayRange: NSRange { get }

	/// Dictionary representation
	var dictionary: [String: AnyObject] { get }

	func contentInString(string: String) -> String
}


extension Node {
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(displayRange)
	}

	// TODO: Remove this
	public var dictionary: [String: AnyObject] {
		return [:]
	}
}
