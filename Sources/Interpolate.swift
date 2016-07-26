//
//  Interpolate.swift
//  Canvas
//
//  Created by Sam Soffes on 7/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

func interpolate(start start: CGFloat, end: CGFloat, progress: CGFloat) -> CGFloat {
	return (end - start) * progress + start
}


extension UIColor {
	func interpolateTo(color end: UIColor, progress: CGFloat) -> UIColor {
		var r1: CGFloat = 0
		var g1: CGFloat = 0
		var b1: CGFloat = 0
		var a1: CGFloat = 0
		getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

		var r2: CGFloat = 0
		var g2: CGFloat = 0
		var b2: CGFloat = 0
		var a2: CGFloat = 0
		end.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

		return UIColor(
			red: interpolate(start: r1, end: r2, progress: progress),
			green: interpolate(start: g1, end: g2, progress: progress),
			blue: interpolate(start: b1, end: b2, progress: progress),
			alpha: interpolate(start: a1, end: a2, progress: progress)
		)
	}
}
