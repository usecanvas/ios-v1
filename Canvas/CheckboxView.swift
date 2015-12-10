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
		if checklist.completion == .Complete {
			Color.brand.setFill()
			UIBezierPath(roundedRect: bounds, cornerRadius: 3).fill()

			if let checkmark = UIImage(named: "checkmark") {
				Color.white.setFill()
				checkmark.drawAtPoint(CGPoint(x: (bounds.width - checkmark.size.width) / 2, y: (bounds.height - checkmark.size.height) / 2))
			}
			return
		}

		Color.gray.setStroke()
		let path = UIBezierPath(roundedRect: CGRectInset(bounds, 1, 1), cornerRadius: 3)
		path.lineWidth = 2
		path.stroke()
	}

	override func sizeThatFits(size: CGSize) -> CGSize {
		return intrinsicContentSize()
	}

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 16, height: 16)
	}
}
