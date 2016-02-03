//
//  BlockSpacing.swift
//  CanvasText
//
//  Created by Sam Soffes on 2/3/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit
#else
	import UIKit
#endif

import CanvasNative

public struct BlockSpacing {

	// MARK: - Properties

	public var paddingLeft: CGFloat
	public var paddingRight: CGFloat
	public var marginTop: CGFloat
	public var marginBottom: CGFloat

	public static let zero = BlockSpacing(paddingLeft: 0, paddingRight: 0, marginTop: 0, marginBottom: 0)


	// MARK: - Initializers

	public init(paddingLeft: CGFloat, paddingRight: CGFloat, marginTop: CGFloat, marginBottom: CGFloat) {
		self.paddingLeft = paddingLeft
		self.paddingRight = paddingRight
		self.marginTop = marginTop
		self.marginBottom = marginBottom
	}


	// MARK: - Utilities

	public func apply(rect: CGRect) -> CGRect {
		var output = rect

		// Padding left
		output.origin.x += paddingLeft
		output.size.width -= paddingLeft

		// Padding right
		output.size.width -= paddingRight

		// Margin top
		output.origin.y += marginTop

		// Margin bottom
		output.size.height += marginBottom

		return output
	}
}
