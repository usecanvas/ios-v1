//
//  UIColor+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 6/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIColor {
	var desaturated: UIColor {
		var hue: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0

		getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
		
		return self.dynamicType.init(hue: hue, saturation: 0, brightness: brightness, alpha: alpha)
	}
}
