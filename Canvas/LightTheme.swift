//
//  LightTheme.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative
import CanvasText
import UIKit

struct LightTheme: Theme {

	// MARK: - Properties

	let fontSize: CGFloat = 18
	let backgroundColor = UIColor(white: 1, alpha: 1)
	let foregroundColor = UIColor(white: 0.133, alpha: 1)
	let placeholderColor = Color.gray
	var tintColor = Color.brand

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
		return paragraph
	}

	var baseAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize),
			NSParagraphStyleAttributeName: baseParagraph
		]
	}

	var foldingAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: UIColor(red: 0.847, green: 0.847, blue: 0.863, alpha: 1)
		]
	}

	var titleAttributes: Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
		attributes[NSFontAttributeName] = fontOfSize(fontSize * 1.7, style: [.Bold])
		return attributes
	}

	func blockSpacing(node node: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing {
		var spacing = BlockSpacing(marginBottom: fontSize * 1.5)

		// Large left padding on title for icon
		if node is Title {
			spacing.paddingLeft = 32
			return spacing
		}

		// No margin if it's not at the bottom of a positionable list
		if let node = node as? Positionable where !(node is Blockquote) {
			if !node.position.isBottom {
				spacing.marginBottom = 0
			}
		}

		// Heading spacing
		if node is Heading {
			spacing.marginTop = spacing.marginBottom * 0.25
			spacing.marginBottom /= 2
			return spacing
		}

		// Indentation
		if let listable = node as? Listable {
			spacing.paddingLeft = listIndentation * CGFloat(listable.indentation.rawValue + 1)
			return spacing
		}

		if let node = node as? CodeBlock {
			// Top margin
			if node.position.isTop {
				spacing.marginTop += 4
			}

			if node.position.isBottom {
				spacing.marginBottom += 4
			}

			// Indent
			if horizontalSizeClass == .Regular {
				// TODO: Use a constant
				spacing.paddingLeft = 48
			} else {
				spacing.paddingLeft = listIndentation
			}
			
			return spacing
		}

		if node is Blockquote {
			spacing.paddingLeft = listIndentation
			return spacing
		}

		return spacing
	}

	func attributesForNode(node: Node, currentFont: CanvasText.Font?) -> Attributes {
		if node is Title {
			return titleAttributes
		}

		let fontSize = currentFont?.pointSize ?? self.fontSize

		var attributes = baseAttributes
		attributes[NSParagraphStyleAttributeName] = nil

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
		}

		else if node is CodeBlock {
			attributes[NSForegroundColorAttributeName] = mediumGray
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)

			paragraph.headIndent = fontSize
		}

		else if node is Blockquote {
			attributes[NSForegroundColorAttributeName] = mediumGray
		}

		else if node is CodeSpan {
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)
			attributes[NSForegroundColorAttributeName] = UIColor(red: 0.494, green: 0.494, blue: 0.510, alpha: 1)
			attributes[NSBackgroundColorAttributeName] = UIColor(red: 0.961, green: 0.961, blue: 0.965, alpha: 1)
		}

		else if node is DoubleEmphasis {
			var style = FontStyle.Bold

			#if !os(OSX)
				if let traits = currentFont?.fontDescriptor().symbolicTraits where traits.contains(.TraitItalic) {
					style.insert(.Italic)
				}
			#endif

			attributes[NSFontAttributeName] = fontOfSize(fontSize, style: style)
		}

		else if node is Emphasis {
			var style = FontStyle.Italic

			#if !os(OSX)
				if let traits = currentFont?.fontDescriptor().symbolicTraits where traits.contains(.TraitBold) {
					style.insert(.Bold)
				}
			#endif

			attributes[NSFontAttributeName] = fontOfSize(fontSize, style: style)
		}

		else if node is Link {
			attributes[NSForegroundColorAttributeName] = tintColor
		}

		if node is BlockNode {
			attributes[NSParagraphStyleAttributeName] = paragraph
		}

		return attributes
	}
}
