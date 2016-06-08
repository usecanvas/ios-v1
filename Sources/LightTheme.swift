//
//  LightTheme.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText
import CanvasNative
import X

struct LightTheme: Theme {

	// MARK: - Properties

	let fontSize: CGFloat = 18
	let backgroundColor = Color.white
	let foregroundColor = Color.black
	let placeholderColor = Color.lightGray
	var tintColor: X.Color

	let bulletColor = Color.gray
	let uncheckedCheckboxColor = Color.gray
	let orderedListItemNumberColor = Color.gray
	let horizontalRuleColor = Color.gray

	let codeColor = Color.gray
	let codeBlockBackgroundColor = Color.extraLightGray
	let codeBlockLineNumberColor = Color.lightGray
	let codeBlockLineNumberBackgroundColor = Color.lightGray

	let blockquoteColor = Color.gray
	let blockquoteBorderColor = Color.lightGray

	let commentBackgroundColor = X.Color(red: 1, green: 0.942, blue: 0.716, alpha: 1)

	let placeholderImageColor = Color.gray
	let placeholderImageBackgroundColor = Color.extraLightGray

	let strikethroughColor = Color.gray
	let linkURLColor = Color.gray

	private let smallParagraphSpacing: CGFloat

	private var listIndentation: CGFloat {
		return round(fontSize * 1.1)
	}


	// MARK: - Initializers

	init(tintColor: X.Color) {
		self.tintColor = tintColor
		smallParagraphSpacing = round(fontSize * 0.1)
	}


	// MARK: - Theme

	func foldingAttributes(currentFont currentFont: X.Font) -> Attributes {
		var attributes = baseAttributes
		attributes[NSForegroundColorAttributeName] = Color.gray
		attributes[NSFontAttributeName] = currentFont
		return attributes
	}

	func blockSpacing(block block: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing {
		var spacing = BlockSpacing(marginBottom: round(fontSize * 1.5))

		// No margin if it's not at the bottom of a positionable list
		if let block = block as? Positionable where !(block is Blockquote) {
			if !block.position.isBottom {
				spacing.marginBottom = 4
			}
		}

		// Heading spacing
		if block is Heading {
			spacing.marginTop = round(spacing.marginBottom * 0.25)
			spacing.marginBottom = round(spacing.marginBottom / 2)
			return spacing
		}

		// Indentation
		if let listable = block as? Listable {
			spacing.paddingLeft = round(listIndentation * CGFloat(listable.indentation.rawValue + 1))
			return spacing
		}

		if let code = block as? CodeBlock {
			let padding: CGFloat = 16
			let margin: CGFloat = 5

			// Top margin
			if code.position.isTop {
				spacing.paddingTop += padding
				spacing.marginTop += margin
			}

			// Bottom margin
			if code.position.isBottom {
				spacing.paddingBottom += padding
				spacing.marginBottom += margin
			}

			spacing.paddingLeft = listIndentation

			// Indent for line numbers
			if horizontalSizeClass == .Regular {
				// TODO: Don't hard code
				spacing.paddingLeft += 40
			}

			return spacing
		}

		if let blockquote = block as? Blockquote {
			let padding: CGFloat = 4

			// Top margin
			if blockquote.position.isTop {
				spacing.paddingTop += padding
			}

			// Bottom margin
			if blockquote.position.isBottom {
				spacing.paddingBottom += padding
			}

			spacing.paddingLeft = listIndentation

			return spacing
		}

		return spacing
	}

	func attributes(block block: BlockNode) -> Attributes {
		if block is Title {
			return titleAttributes
		}

		var attributes = baseAttributes

		if let heading = block as? Heading {
			switch heading.level {
			case .One:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.5), symbolicTraits: .TraitBold)
			case .Two:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.2), symbolicTraits: .TraitBold)
			case .Three:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(round(fontSize * 1.1), symbolicTraits: .TraitBold)
			case .Four:
				attributes[NSForegroundColorAttributeName] = foregroundColor
				attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: .TraitBold)
			case .Five:
				attributes[NSForegroundColorAttributeName] = foregroundColor
			case .Six:
				attributes[NSForegroundColorAttributeName] = foregroundColor
			}
		}

		else if block is CodeBlock {
			attributes[NSForegroundColorAttributeName] = codeColor
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize)

			// Indent wrapped lines in code blocks
			let paragraph = NSMutableParagraphStyle()
			paragraph.headIndent = floor(fontSize * 1.2) + 0.5
			attributes[NSParagraphStyleAttributeName] = paragraph
		}

		else if block is Blockquote {
			attributes[NSForegroundColorAttributeName] = blockquoteColor
		}

		return attributes
	}

	func attributes(span span: SpanNode, currentFont: X.Font) -> Attributes? {
		var traits = currentFont.symbolicTraits
		var attributes = Attributes()

		if span is CodeSpan {
			attributes[NSFontAttributeName] = monospaceFontOfSize(fontSize, symbolicTraits: traits)
			attributes[NSForegroundColorAttributeName] = Color.gray
			attributes[NSBackgroundColorAttributeName] = Color.extraLightGray
		}

		else if span is Strikethrough {
			attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.StyleThick.rawValue
			attributes[NSStrikethroughColorAttributeName] = strikethroughColor
			attributes[NSForegroundColorAttributeName] = strikethroughColor
		}

		else if span is DoubleEmphasis {
			traits.insert(.TraitBold)
			attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: traits)
		}

		else if span is Emphasis {
			traits.insert(.TraitItalic)
			attributes[NSFontAttributeName] = fontOfSize(fontSize, symbolicTraits: traits)
		}

		else if span is Link {
			attributes[NSForegroundColorAttributeName] = tintColor
		}

		// If there aren't any attributes set yet, return nil and inherit from parent.
		if attributes.isEmpty {
			return nil
		}

		// Ensure a font is set
		if attributes[NSFontAttributeName] == nil {
			attributes[NSFontAttributeName] = currentFont
		}
		
		return attributes
	}
}
