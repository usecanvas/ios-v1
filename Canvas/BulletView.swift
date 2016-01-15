//
//  BulletView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/17/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

final class BulletView: UIView {

	// MARK: - Properties

	let unorderedList: UnorderedListItem

	// MARK: - Initializers

	init(frame: CGRect, unorderedList: UnorderedListItem) {
		self.unorderedList = unorderedList

		super.init(frame: frame)

		userInteractionEnabled = false
		backgroundColor = .clearColor()
		contentMode = .Redraw
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func drawRect(rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }

		Color.gray.set()

		if unorderedList.indentation.isFilled {
			CGContextFillEllipseInRect(context, bounds)
		} else {
			CGContextSetLineWidth(context, 2)
			CGContextStrokeEllipseInRect(context, CGRectInset(bounds, 1, 1))
		}
	}

	override func sizeThatFits(size: CGSize) -> CGSize {
		return intrinsicContentSize()
	}

	override func intrinsicContentSize() -> CGSize {
		return CGSize(width: 8, height: 8)
	}
}
