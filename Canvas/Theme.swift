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
	
	static let baseFontSize: CGFloat = 18

	static let listIndentation: CGFloat = 20
	
	static let baseAttributes = [
		NSBackgroundColorAttributeName: UIColor.whiteColor(),
		NSForegroundColorAttributeName: UIColor(hex: "#222")!,
		NSFontAttributeName: UIFont.systemFontOfSize(baseFontSize)
	]
	
	static func attributesForNode(node: Node, nextSibling: Node? = nil) -> [String: AnyObject] {
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineHeightMultiple = 1.2
		paragraph.paragraphSpacing = baseFontSize * 1.5
		
		var attributes: [String: AnyObject] = [
			NSParagraphStyleAttributeName: paragraph
		]

		if node is DocHeading {
			attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 2)
		}

		else if let heading = node as? Heading {
			switch heading.level {
			case .One:
				attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
				attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.5)
			case .Two:
				attributes[NSForegroundColorAttributeName] = UIColor(hex: "#222")!
				attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.2)
			case .Three:
				attributes[NSForegroundColorAttributeName] = UIColor(hex: "#4d4d4d")!
				attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.1)
			case .Four:
				attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
				attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize)
			case .Five:
				attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			case .Six:
				attributes[NSForegroundColorAttributeName] = UIColor(hex: "#9a9a9a")!
			}

			paragraph.paragraphSpacing = baseFontSize * 0.5
		}

		else if node is CodeBlock {
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			attributes[NSFontAttributeName] = UIFont(name: "Menlo", size: baseFontSize)!
		}

		else if node is Blockquote {
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#3da25f")!
		}

		else if let listable = node as? Listable {
			let indent = listIndentation * CGFloat(listable.indentation.rawValue + 1)
			paragraph.firstLineHeadIndent = indent
			paragraph.headIndent = indent

			// Smaller bottom margin if the next block is a list type
			if let nextSibling = nextSibling where nextSibling is Listable {
				paragraph.paragraphSpacing = baseFontSize * 0.25
			}
		}

		return attributes
	}
}
