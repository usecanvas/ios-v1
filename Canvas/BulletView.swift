//
//  BulletView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class BulletView: UIView {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .whiteColor()
		contentMode = .Redraw
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }

		UIColor(red: 0.847, green: 0.847, blue: 0.863, alpha: 1).setFill()
		CGContextFillEllipseInRect(context, CGRectInset(bounds, 0.5, 0.5))
	}

	override func sizeThatFits(size: CGSize) -> CGSize {
		return intrinsicContentSize()
	}

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 9, height: 9)
	}
}
