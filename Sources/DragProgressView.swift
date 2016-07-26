//
//  DragProgressView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/20/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class DragProgressView: UIView {

	// MARK: - Properties

	private let imageView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = Swatch.gray
		view.contentMode = .Center
		return view
	}()


	// MARK: - Initializers

	init(icon: UIImage?, isLeading: Bool) {
		super.init(frame: .zero)
		backgroundColor = Swatch.extraLightGray
		userInteractionEnabled = false

		imageView.image = icon
		addSubview(imageView)

		imageView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true

		if isLeading {
			let x = imageView.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -8)
			x.priority = UILayoutPriorityDefaultLow

			NSLayoutConstraint.activateConstraints([
				x,
				imageView.trailingAnchor.constraintLessThanOrEqualToAnchor(leadingAnchor, constant: DragContext.threshold)
			])
		} else {
			let x = imageView.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8)
			x.priority = UILayoutPriorityDefaultLow

			NSLayoutConstraint.activateConstraints([
				x,
				imageView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(trailingAnchor, constant: -DragContext.threshold)
			])
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - Translation

	func translate(x x: CGFloat) {
		let progress = min(abs(x) / DragContext.threshold, 1)
		imageView.tintColor = Swatch.extraLightGray.interpolateTo(color: Swatch.darkGray, progress: progress)
	}
}
