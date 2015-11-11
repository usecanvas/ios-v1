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
	
	static func attributesForLine(line: Line) -> [String: AnyObject] {
		let paragraph = NSMutableParagraphStyle()
		paragraph.paragraphSpacing = baseFontSize * 1.5
		
		var attributes: [String: AnyObject] = [
			NSParagraphStyleAttributeName: paragraph
		]
		
		switch line.kind {
		case .DocHeading:
			attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 2)
		case .Heading1:
			attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.5)
		case .Heading2:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#222")!
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.2)
		case .Heading3:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#4d4d4d")!
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize * 1.1)
		case .Heading4:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			attributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(baseFontSize)
		case .Heading5:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
		case .Heading6:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#9a9a9a")!
		case .Code:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#808080")!
			attributes[NSFontAttributeName] = UIFont(name: "Menlo", size: baseFontSize)!
		case .Blockquote:
			attributes[NSForegroundColorAttributeName] = UIColor(hex: "#3da25f")!
		default: break
		}
		
		return attributes
	}
}
