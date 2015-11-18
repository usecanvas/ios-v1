//
//  BlockElement.swift
//  Canvas
//
//  Created by Sam Soffes on 11/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

public struct BlockElement: Equatable {
	
	// MARK: - Types
	
	public enum Kind: String {

		// MARK: - Cases

		case Checklist = "checklist-0"			// TODO: Nesting
		case Comment = "comment"
		case Blockquote = "blockquote"
		case Code = "code"
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
		case OrderedList = "ordered-list-0"		// TODO: Nesting
		case UnorderedList = "unordered-list-0"	// TODO: Nesting
		case Paragraph = "paragraph"


		// MARK: - Properties

		/// These are included after the delimiter (on in place of for some) and should be stripped.
		public var prefix: String? {
			switch self {
			case .Blockquote: return "> "
			case .Heading1: return "# "
			case .Heading2: return "## "
			case .Heading3: return "### "
			case .Heading4: return "#### "
			case .Heading5: return "##### "
			case .Heading6: return "###### "
			case .UnorderedList: return "- "
			case .OrderedList: return "1. "
			case .Checklist: return "- [ ] " // TODO: or `- [x] `
			default: return nil
			}
		}

		public var isListItem: Bool {
			return self == .OrderedList || self == .UnorderedList || self == .Checklist
		}


		// MARK: - Initializers

		init?(headingLevel: UInt) {
			if headingLevel == 1 {
				self = .Heading1
				return
			}

			if headingLevel == 2 {
				self = .Heading2
				return
			}

			if headingLevel == 3 {
				self = .Heading3
				return
			}

			if headingLevel == 4 {
				self = .Heading4
				return
			}

			if headingLevel == 5 {
				self = .Heading5
				return
			}

			if headingLevel == 6 {
				self = .Heading6
				return
			}

			return nil
		}
	}

	
	// MARK: - Properties
	
	public var kind: Kind
	public var delimiterRange: NSRange?
	public var prefixRange: NSRange?
	public var contentRange: NSRange

	static let leadingDelimiter = "⧙"
	static let trailingDelimiter = "⧘"
	
	
	// MARK: - Initializers
	
	public init(kind: Kind, delimiterRange: NSRange? = nil, prefixRange: NSRange? = nil, contentRange: NSRange) {
		self.kind = kind
		self.delimiterRange = delimiterRange
		self.prefixRange = prefixRange
		self.contentRange = contentRange
	}
	
	
	// MARK: - Text
	
	public func contentInString(string: String) -> String {
		return (string as NSString).substringWithRange(contentRange)
	}
}


public func ==(lhs: BlockElement, rhs: BlockElement) -> Bool {
		return lhs.kind == rhs.kind
			&& lhs.delimiterRange == rhs.delimiterRange
			&& lhs.prefixRange == rhs.prefixRange
			&& lhs.contentRange == rhs.contentRange
}
