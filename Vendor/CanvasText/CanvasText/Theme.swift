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
	func monospaceFontOfSize(fontSize: CGFloat) -> Font

	func attributesForNode(node: Node, currentFont: Font?) -> Attributes

	func blockSpacing(node node: BlockNode, horizontalSizeClass: UserInterfaceSizeClass) -> BlockSpacing
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
		var font = Font.systemFontOfSize(fontSize)

		#if !os(OSX)
			if style != [] {
				var descriptor = font.fontDescriptor()

				if style.contains(.Bold) && style.contains(.Italic) {
					descriptor = descriptor.fontDescriptorWithSymbolicTraits([.TraitBold, .TraitItalic])
				} else if style.contains(.Bold) {
					descriptor = descriptor.fontDescriptorWithSymbolicTraits([.TraitBold])
				} else if style.contains(.Italic) {
					descriptor = descriptor.fontDescriptorWithSymbolicTraits([.TraitItalic])
				}

				font = UIFont(descriptor: descriptor, size: font.pointSize)
			}
		#endif

		return font
	}

	public func monospaceFontOfSize(fontSize: CGFloat) -> Font {
		let font = Font(name: "Menlo", size: fontSize)
		return font ?? fontOfSize(fontSize)
	}
}
