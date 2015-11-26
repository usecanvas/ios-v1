//
//  Image+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import CanvasText
import UIKit

extension Image {
	static func placeholderImage(size size: CGSize, scale: CGFloat? = 0) -> UIImage? {
		guard let icon = UIImage(named: "ImagePlaceholder") else { return nil }

		let rect = CGRect(origin: .zero, size: size)

		UIGraphicsBeginImageContextWithOptions(size, true, scale ?? 0)

		// Background
		UIColor(red: 0.957, green: 0.976, blue: 1, alpha: 1).setFill()
		UIBezierPath(rect: rect).fill()

		// Icon
		UIColor(red: 0.729, green: 0.773, blue: 0.835, alpha: 1).setFill()
		let iconFrame = CGRect(
			x: (size.width - icon.size.width) / 2,
			y: (size.height - icon.size.height) / 2,
			width: icon.size.width,
			height: icon.size.height
		)
		icon.drawInRect(iconFrame)

		let image = UIGraphicsGetImageFromCurrentImageContext()

		UIGraphicsEndImageContext()

		return image
	}
}
