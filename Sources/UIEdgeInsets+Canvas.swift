//
//  UIEdgeInsets+Canvas.swift
//  Canvas
//
//  Created by Sam Soffes on 11/26/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
	init(_ value: CGFloat) {
		top = value
		left = value
		right = value
		bottom = value
	}

	static let zero = UIEdgeInsets(0)
}
