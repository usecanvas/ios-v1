//
//  Line+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 11/11/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

struct Theme {
	
	static let baseFontSize: CGFloat = 16
	
	static let baseAttributes = [
		NSBackgroundColorAttributeName: UIColor.whiteColor(),
		NSForegroundColorAttributeName: UIColor(hex: "#222")!,
		NSFontAttributeName: UIFont.systemFontOfSize(baseFontSize)
	]
	
	static func attributesForBlock(block: BlockElement) -> [String: AnyObject] {
		let paragraph = NSMutableParagraphStyle()
		paragraph.paragraphSpacing = baseFontSize * 1.5
		
		var attributes: [String: AnyObject] = [
			NSParagraphStyleAttributeName: paragraph,
			"Canvas.Block.Kind": block.kind.rawValue,
			"Canvas.Block.Kind.\(block.kind.rawValue)": true
		]

		let headingBottomMargin = baseFontSize * 0.1
		
		switch block.kind {
		// Document heading
		case .DocHeading:
			attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 2)

		// Headings
		case .Heading1:
			attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.5)
			paragraph.paragraphSpacing = headingBottomMargin
		case .Heading2:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#222")!
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.2)
			paragraph.paragraphSpacing = headingBottomMargin
		case .Heading3:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#4d4d4d")!
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.1)
			paragraph.paragraphSpacing = headingBottomMargin
		case .Heading4:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize)
			paragraph.paragraphSpacing = headingBottomMargin
		case .Heading5:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			paragraph.paragraphSpacing = headingBottomMargin
		case .Heading6:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#9a9a9a")!
			paragraph.paragraphSpacing = headingBottomMargin

		// Code
		case .Code:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			attributes[NSFontAttributeName] = UIFont(name: "Menlo", size: baseFontSize)!

		// Blockquote
		case .Blockquote:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#3da25f")!

		// List items
		case .UnorderedList, .OrderedList, .Checklist:
			paragraph.firstLineHeadIndent = 32
			paragraph.headIndent = 32
			paragraph.paragraphSpacing = baseFontSize * 0.25

		default: break
		}
		
		return attributes
	}
}
