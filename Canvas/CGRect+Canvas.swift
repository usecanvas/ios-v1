//
//  CGRect+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CoreGraphics

extension CGRect {
	var ceil: CGRect {
		return CGRect(
			x: CoreGraphics.ceil(origin.x),
			y: CoreGraphics.ceil(origin.y),
			width: CoreGraphics.ceil(size.width),
			height: CoreGraphics.ceil(size.height)
		)
	}
}
