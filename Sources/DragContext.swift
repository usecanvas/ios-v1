//
//  DragContext.swift
//  Canvas
//
//  Created by Sam Soffes on 5/4/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

enum DragAction: String {
	case Increase
	case Decrease
}

struct DragContext {

	// MARK: - Properties

	let block: BlockNode
	let rect: CGRect
	let yContentOffset: CGFloat
	var dragAction: DragAction? = nil

	let contentView = UIView()

	private let backgroundView: UIView = {
		let view = DragBackgroundView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let leadingProgressView: DragProgressView = {
		let view = DragProgressView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let trailingProgressView: DragProgressView = {
		let view = DragProgressView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let snapshotView: UIView
	private let snapshotLeadingConstraint: NSLayoutConstraint
	private let dragThreshold: CGFloat = 60
	

	// MARK: - Initializers

	init(block: BlockNode, snapshotView: UIView, rect: CGRect, yContentOffset: CGFloat) {
		self.block = block
		self.snapshotView = snapshotView
		self.rect = rect
		self.yContentOffset = yContentOffset
		snapshotLeadingConstraint = snapshotView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor)

		let snapshotSize = snapshotView.bounds.size
		snapshotView.userInteractionEnabled = false
		snapshotView.translatesAutoresizingMaskIntoConstraints = false

		contentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)

		contentView.addSubview(backgroundView)
		contentView.addSubview(leadingProgressView)
		contentView.addSubview(trailingProgressView)
		contentView.addSubview(snapshotView)

		NSLayoutConstraint.activateConstraints([
			backgroundView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
			backgroundView.trailingAnchor.constraintEqualToAnchor(contentView.trailingAnchor),
			backgroundView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: -4),
			backgroundView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: 4),

			leadingProgressView.leadingAnchor.constraintLessThanOrEqualToAnchor(contentView.leadingAnchor),
			leadingProgressView.trailingAnchor.constraintEqualToAnchor(snapshotView.leadingAnchor),
			leadingProgressView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor),
			leadingProgressView.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor),

			trailingProgressView.leadingAnchor.constraintEqualToAnchor(snapshotView.trailingAnchor),
			trailingProgressView.trailingAnchor.constraintGreaterThanOrEqualToAnchor(contentView.trailingAnchor),
			trailingProgressView.topAnchor.constraintEqualToAnchor(backgroundView.topAnchor),
			trailingProgressView.bottomAnchor.constraintEqualToAnchor(backgroundView.bottomAnchor),

			snapshotLeadingConstraint,
			snapshotView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: -rect.minY + yContentOffset),
			snapshotView.widthAnchor.constraintEqualToConstant(snapshotSize.width),
			snapshotView.heightAnchor.constraintEqualToConstant(snapshotSize.height)
		])

		// Setup snapshot mask
		let mask = CAShapeLayer()
		mask.frame = snapshotView.layer.bounds
		mask.path = UIBezierPath(rect: rectForContentViewMask()).CGPath
		snapshotView.layer.mask = mask
	}


	// MARK: - Manipulation

	func translate(x x: CGFloat) {
		snapshotLeadingConstraint.constant = x
		contentView.layoutIfNeeded()
	}

	func tearDown() {
		contentView.removeFromSuperview()
	}


	// MARK: - Private

	private func rectForContentViewMask() -> CGRect {
		var rect = self.rect
		rect.origin.x = 0
		rect.origin.y -= yContentOffset
		rect.size.width = snapshotView.bounds.size.width
		return rect
	}
}
