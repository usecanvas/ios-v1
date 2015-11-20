//
//  CheckboxView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class CheckboxView: UIButton {

	// MARK: - Properties

	let checklist: Checklist

	// MARK: - Initializers

	init(frame: CGRect, checklist: Checklist) {
		self.checklist = checklist
		super.init(frame: frame)
		contentMode = .Redraw
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2)
		let path = UIBezierPath(roundedRect: CGRectInset(bounds, 1, 1), cornerRadius: 4)

		if checklist.completed {
			Color.brand.setFill()
			path.fill()
		} else {
			UIColor(red: 0.847, green: 0.847, blue: 0.863, alpha: 1).setStroke()
			path.stroke()
		}
	}
}
