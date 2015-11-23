//
//  Theme.swift
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

public typealias Attributes = [String: AnyObject]

public protocol Theme {

	var fontSize: CGFloat { get }

	var listIndentation: CGFloat { get }

	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var baseAttributes: Attributes { get }

	func fontOfSize(fontSize: CGFloat, style: FontStyle) -> Font
	func monospaceFontOfSize(fontSize: CGFloat, style: FontStyle) -> Font

	func attributesForNode(node: Node, nextSibling: Node?) -> Attributes
}


extension Theme {
	public var listIndentation: CGFloat {
		return round(fontSize * 1.1)
	}

	public var baseAttributes: [String: AnyObject] {
		return [
			NSBackgroundColorAttributeName: backgroundColor,
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize)
		]
	}

	public func fontOfSize(fontSize: CGFloat, style: FontStyle = []) -> Font {
		if style == [.Bold] {
			return Font.boldSystemFontOfSize(fontSize)
		}

		if style == [.Italic] {
			return Font.italicSystemFontOfSize(fontSize)
		}

		// TODO: Bold italic

		return Font.systemFontOfSize(fontSize)
	}

	public func monospaceFontOfSize(fontSize: CGFloat, style: FontStyle = []) -> Font {
		let font: Font?

		if style == [.Bold] {
			font = Font(name: "Menlo-Bold", size: fontSize)
		} else if style == [.Italic] {
			font = Font(name: "Menlo-Italic", size: fontSize)
		} else if style == [.Bold, .Italic] {
			font = Font(name: "Menlo-BoldItalic", size: fontSize)
		} else {
			font = Font(name: "Menlo", size: fontSize)
		}

		return font ?? fontOfSize(fontSize, style: style)
	}
}
