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

	let fontSize: CGFloat = 18
	let backgroundColor = UIColor(white: 1, alpha: 1)
	let foregroundColor = UIColor(white: 0.133, alpha: 1)
	let placeholderColor = Color.gray

	let lineHeightMultiple: CGFloat = 1.2
	
	private let smallParagraphSpacing: CGFloat
	private let mediumGray = UIColor(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)


	// MARK: - Initializers

	init() {
		smallParagraphSpacing = fontSize * 0.1
	}


	// MARK: - Theme

	private var baseParagraph: NSMutableParagraphStyle {
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineHeightMultiple = lineHeightMultiple
		paragraph.paragraphSpacing = paragraphSpacing
		return paragraph
	}

	var baseAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize),
			NSParagraphStyleAttributeName: baseParagraph
		]
	}

	var titleAttributes: Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
		attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.7, style: [.Bold])

		let paragraph = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? baseParagraph
		paragraph.firstLineHeadIndent = 32
		paragraph.headIndent = 32
		attributes[NSParagraphStyleAttributeName] = paragraph

		return attributes
	}

	func fontOfSize(fontSize: CGFloat, style: FontStyle = []) -> CanvasText.Font {
		if style == [.Bold] {
			return Font.sansSerif(weight: .Bold, pointSize: fontSize)
		}

		// TODO: Italic
		// TODO: Bold italic

		return Font.sansSerif(pointSize: fontSize)
	}

	func attributesForNode(node: Node, nextSibling: Node? = nil, horizontalSizeClass: UserInterfaceSizeClass) -> Attributes {
		if node is Title {
			return titleAttributes
		}

		var attributes = baseAttributes
		let paragraph = baseParagraph

		if let heading = node as? Heading {
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

			if horizontalSizeClass == .Regular {
				// TODO: Use a constant
				paragraph.firstLineHeadIndent = 48
				paragraph.headIndent = 48 + listIndentation
			} else {
				paragraph.headIndent = listIndentation
			}

			// No bottom margin if the next block is a code block
			if nextSibling is CodeBlock {
				paragraph.paragraphSpacing = 0
			} else {
				paragraph.paragraphSpacing += paragraphSpacing / 2
			}
		}

		else if node is Blockquote {
			attributes[NSForegroundColorAttributeName] = mediumGray
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


		if !(node is CodeBlock) && nextSibling is CodeBlock {
			paragraph.paragraphSpacing += paragraphSpacing / 2
		}

		attributes[NSParagraphStyleAttributeName] = paragraph

		return attributes
	}
}
