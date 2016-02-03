//
//  Theme.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit

	public enum UserInterfaceSizeClass: Int {
		case Unspecified
		case Compact
		case Regular
	}
#else
	import UIKit
	public typealias UserInterfaceSizeClass = UIUserInterfaceSizeClass
#endif

import CanvasNative

public typealias Attributes = [String: AnyObject]

public protocol Theme {

	var fontSize: CGFloat { get }

	// TODO: Remove
	var listIndentation: CGFloat { get }

	var backgroundColor: Color { get }
	var foregroundColor: Color { get }
	var placeholderColor: Color { get }
	var tintColor: Color { get set }
	var foldingAttributes: Attributes { get }
	var baseAttributes: Attributes { get }
	var titleAttributes: Attributes { get }

	var lineHeightMultiple: CGFloat { get }

	func fontOfSize(fontSize: CGFloat, style: FontStyle) -> Font
	func monospaceFontOfSize(fontSize: CGFloat, style: FontStyle) -> Font

	func attributesForNode(node: Node) -> Attributes

	func blockSpacing(node node: BlockNode, nextSibling: BlockNode?, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing
}


extension Theme {
	// TODO: Remove
	public var listIndentation: CGFloat {
		return round(fontSize * 1.1)
	}

	public var foldingAttributes: Attributes {
		return [
			NSForegroundColorAttributeName: placeholderColor
		]
	}

	public var baseAttributes: Attributes {
		return [
//			NSBackgroundColorAttributeName: backgroundColor,
			NSForegroundColorAttributeName: foregroundColor,
			NSFontAttributeName: fontOfSize(fontSize)
		]
	}

	public var titleAttributes: Attributes {
		return baseAttributes
	}

	public func fontOfSize(fontSize: CGFloat, style: FontStyle = []) -> Font {
		if style == [.Bold] {
			return Font.boldSystemFontOfSize(fontSize)
		}

		// TODO: Italic on OS X
		#if !os(OSX)
			if style == [.Italic] {
				return Font.italicSystemFontOfSize(fontSize)
			}
		#endif

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
