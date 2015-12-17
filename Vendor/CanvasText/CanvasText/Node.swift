//
//  Node.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/19/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public protocol Node {

	var range: NSRange { get }
	var contentRange: NSRange { get }

	init?(string: String, enclosingRange: NSRange)

	func contentInString(string: String) -> String

	var hasAnnotation: Bool { get }
	var allowsReturnCompletion: Bool { get }
}


extension Node {
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(contentRange)
	}

	public var hasAnnotation: Bool {
		return false
	}

	public var allowsReturnCompletion: Bool {
		return true
	}
}

let nodeParseOrder: [Node.Type] = [
	Blockquote.self,
	Checklist.self,
	CodeBlock.self,
	Title.self,
	Heading.self,
	Image.self,
	OrderedList.self,
	UnorderedList.self,
	Paragraph.self
]
