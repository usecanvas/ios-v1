//
//  KeyboardSelectionView.swift
//  Canvas
//
//  Created by Sam Soffes on 12/10/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

/// Used to denote a row is selected
class KeyboardSelectionView: UIView {

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .clearColor()

		guard let layer = layer as? CAShapeLayer else { return }
		layer.fillColor = Color.brand.CGColor
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class func layerClass() -> AnyClass {
		return CAShapeLayer.self
	}

	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setNeedsLayout()
	}

	override func layoutSubviews() {
		guard let layer = layer as? CAShapeLayer else { return }

		let corners: UIRectCorner = traitCollection.horizontalSizeClass == .Compact ? [.TopRight, .BottomRight] : .AllCorners
		layer.path = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 3, height: 3)).CGPath
	}
}
