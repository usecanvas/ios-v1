//
//  LightTheme.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CanvasText
import UIKit

struct LightTheme: Theme {

	// MARK: - Properties

	let fontSize: CGFloat = 16
	let backgroundColor = UIColor(white: 1, alpha: 1)
	let foregroundColor = UIColor(white: 0.133, alpha: 1)

	let lineHeightMultiple: CGFloat = 1.2
	
	private let smallParagraphSpacing: CGFloat
	private let mediumGray = UIColor(white: 0.5, alpha: 1)


	// MARK: - Initializers

	init() {
		smallParagraphSpacing = fontSize * 0.1
	}


	// MARK: - Theme

	func fontOfSize(fontSize: CGFloat, style: FontStyle = []) -> CanvasText.Font {
		if style == [.Bold] {
			return Font.sansSerif(weight: .Bold, pointSize: fontSize)
		}

		// TODO: Italic
		// TODO: Bold italic

		return Font.sansSerif(pointSize: fontSize)
	}

	func attributesForNode(node: Node, nextSibling: Node? = nil) -> Attributes {
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineHeightMultiple = lineHeightMultiple
		paragraph.paragraphSpacing = paragraphSpacing

		var attributes = [String: AnyObject]()

		if node is DocHeading {
			attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.7, style: [.Bold])
		}

		else if let heading = node as? Heading {
			switch heading.level {
			case .One:
				attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.5, style: [.Bold])
			case .Two:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.2, style: [.Bold])
			case .Three:
				attributes[NSForegroundColorAttributeName] = UIColor(white: 0.3, alpha: 1)
				attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.1, style: [.Bold])
			case .Four:
				attributes[NSForegroundColorAttributeName] = mediumGray
				attributes[NSFontAttributeName] = fontOfSize(fontSize, style: [.Bold])
			case .Five:
				attributes[NSForegroundColorAttributeName] = mediumGray
			case .Six:
				attributes[NSForegroundColorAttributeName] = UIColor(white: 0.6, alpha: 1)
			}

			// Smaller bottom margin if the next block isn’t a heading
			if let nextSibling = nextSibling where !(nextSibling is Heading) {
				paragraph.paragraphSpacing = smallParagraphSpacing
			}
		}

		else if node is CodeBlock {
			attributes[NSForegroundColorAttributeName] = mediumGray
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)

			// No bottom margin if the next block is a code block
			if nextSibling is CodeBlock {
				paragraph.paragraphSpacing = 0
			}
		}

		else if node is Blockquote {
			attributes[NSForegroundColorAttributeName] = UIColor(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)
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
