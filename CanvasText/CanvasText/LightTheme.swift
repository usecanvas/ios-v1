//
//  LightTheme.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

public struct LightTheme: Theme {

	// MARK: - Properties

	public let fontSize: CGFloat = 18
	public let backgroundColor = Color(white: 1, alpha: 1)
	public let foregroundColor = Color(white: 0.133, alpha: 1)

	public let lineHeightMultiple: CGFloat = 1.2
	public let paragraphSpacing: CGFloat
	
	private let smallParagraphSpacing: CGFloat
	private let mediumGray = Color(white: 0.5, alpha: 1)


	// MARK: - Initializers

	public init() {
		paragraphSpacing = fontSize * 1.5
		smallParagraphSpacing = fontSize * 0.1
	}


	// MARK: - Attributes

	public func attributesForNode(node: Node, nextSibling: Node? = nil) -> Attributes {
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineHeightMultiple = lineHeightMultiple
		paragraph.paragraphSpacing = paragraphSpacing

		var attributes = [String: AnyObject]()

		if node is DocHeading {
			attributes[NSForegroundColorAttributeName] = Color.blackColor()
			attributes[NSFontAttributeName] = fontOfSize(fontSize * 2, style: [.Bold])
		}

		else if let heading = node as? Heading {
			switch heading.level {
			case .One:
				attributes[NSForegroundColorAttributeName] = Color.blackColor()
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.5, style: [.Bold])
			case .Two:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.2, style: [.Bold])
			case .Three:
				attributes[NSForegroundColorAttributeName] = Color(white: 0.3, alpha: 1)
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.1, style: [.Bold])
			case .Four:
				attributes[NSForegroundColorAttributeName] = mediumGray
				attributes[NSFontAttributeName] = fontOfSize(fontSize, style: [.Bold])
			case .Five:
				attributes[NSForegroundColorAttributeName] = mediumGray
			case .Six:
				attributes[NSForegroundColorAttributeName] = Color(white: 0.6, alpha: 1)
			}

			// Smaller bottom margin if the next block isn’t a heading
			if let nextSibling = nextSibling where !(nextSibling is Heading) {
				paragraph.paragraphSpacing = smallParagraphSpacing
			}
		}

		else if node is CodeBlock {
			attributes[NSForegroundColorAttributeName] = mediumGray
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)
		}

		else if node is Blockquote {
			attributes[NSForegroundColorAttributeName] = Color(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)
			paragraph.firstLineHeadIndent = listIndentation
			paragraph.headIndent = listIndentation
		}

		else if let listable = node as? Listable {
			let indent = listIndentation * CGFloat(listable.indentation.rawValue + 1)
			paragraph.firstLineHeadIndent = indent
			paragraph.headIndent = indent

			// Smaller bottom margin if the next block is a list type
			if let nextSibling = nextSibling where nextSibling is Listable {
				paragraph.paragraphSpacing = smallParagraphSpacing
			}
		}

		attributes[NSParagraphStyleAttributeName] = paragraph

		return attributes
	}
}
