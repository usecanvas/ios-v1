//
//  CGRect+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CoreGraphics

extension CGRect {
	var floor: CGRect {
		return CGRect(
			x: CoreGraphics.floor(origin.x),
			y: CoreGraphics.floor(origin.y),
			width: CoreGraphics.floor(size.width),
			height: CoreGraphics.floor(size.height)
		)
	}

	var ceil: CGRect {
		return CGRect(
			x: CoreGraphics.ceil(origin.x),
			y: CoreGraphics.ceil(origin.y),
			width: CoreGraphics.ceil(size.width),
			height: CoreGraphics.ceil(size.height)
		)
	}
}
