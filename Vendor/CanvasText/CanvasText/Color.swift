//
//  Color.swift
//  CanvasText
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

#if os(OSX)
	import AppKit.NSColor
	public typealias ColorType = NSColor

	extension NSColor {
		public convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
			self.init(SRGBRed: red, green: green, blue: blue, alpha: alpha)
		}
	}
#else
	import UIKit.UIColor
	public typealias ColorType = UIColor
#endif

public typealias Color = ColorType
