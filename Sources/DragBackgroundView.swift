//
//  DragBackgroundView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

// TODO: Get colors from theme
final class DragBackgroundView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .whiteColor()
		userInteractionEnabled = false

		let topBorder = LineView()
		topBorder.translatesAutoresizingMaskIntoConstraints = false
		addSubview(topBorder)

		let bottomBorder = LineView()
		bottomBorder.translatesAutoresizingMaskIntoConstraints = false
		addSubview(bottomBorder)

		NSLayoutConstraint.activateConstraints([
			topBorder.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			topBorder.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			topBorder.bottomAnchor.constraintEqualToAnchor(topAnchor),

			bottomBorder.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			bottomBorder.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			bottomBorder.topAnchor.constraintEqualToAnchor(bottomAnchor)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
