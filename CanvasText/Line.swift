//
//  Annotation.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct Line: Equatable {
	
	// MARK: - Types
	
	public enum Kind: String {
		case Checklist = "checklist"
		case Comment = "comment"
		case Blockquote = "blockquote"
		case FencedCode = "fenced-code"
		case DocHeading = "doc-heading"
		case Heading1 = "heading-1"
		case Heading2 = "heading-2"
		case Heading3 = "heading-3"
		case Heading4 = "heading-4"
		case Heading5 = "heading-5"
		case Heading6 = "heading-6"
		case HorizontalRule = "horizontal-rule"
		case Image = "image"
		case LinkDefinition = "link-definition"
		case OrderedList = "ordered-list"
		case UnorderedList = "unordered-list"
		case Paragraph = "paragraph"
	}

	
	// MARK: - Properties
	
	public let kind: Kind
	public var delimiter: NSRange?
	public var content: NSRange
	
	static let leadingDelimiter = "⧙"
	static let trailingDelimiter = "⧘"
	static let parseOrder: [Kind] = [.Checklist, .Comment, .Blockquote, .FencedCode, .DocHeading, .Heading1, .Heading2, .Heading3, .Heading4, .Heading5, .Heading6, .HorizontalRule, .Image, .LinkDefinition, .OrderedList, .UnorderedList, .Paragraph]
	
	
	// MARK: - Initializers
	
	public init(kind: Kind, delimiter: NSRange? = nil, content: NSRange) {
		self.kind = kind
		self.delimiter = delimiter
		self.content = content
	}
	
	
	// MARK: - Text
	
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(content)
	}
}


public func ==(lhs: Line, rhs: Line) -> Bool {
		return lhs.kind == rhs.kind && lhs.delimiter == rhs.delimiter && lhs.content == rhs.content
}
