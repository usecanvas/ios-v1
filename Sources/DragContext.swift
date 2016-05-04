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
	let contentView: UIView
	let backgroundView: UIView
	let rect: CGRect
	let yContentOffset: CGFloat
	var dragAction: DragAction? = nil

	private let dragThreshold: CGFloat = 60


	// MARK: - Initializers

	init(block: BlockNode, contentView: UIView, backgroundView: UIView, rect: CGRect, yContentOffset: CGFloat) {
		self.block = block
		self.contentView = contentView
		self.backgroundView = backgroundView
		self.rect = rect
		self.yContentOffset = yContentOffset

		contentView.userInteractionEnabled = false
		backgroundView.userInteractionEnabled = false

		layoutViews()
		setupContentViewMask()
	}


	// MARK: - Manipulation

	func translate(x x: CGFloat) {
		contentView.frame = rectForContentView(x: x)
	}

	func tearDown() {
		backgroundView.removeFromSuperview()
		contentView.removeFromSuperview()
	}


	// MARK: - Private

	private func layoutViews() {
		contentView.frame = rectForContentView(x: 0)
		backgroundView.frame = rectForBackgroundView()
	}

	private func setupContentViewMask() {
		let mask = CAShapeLayer()
		mask.frame = contentView.layer.bounds
		mask.path = UIBezierPath(rect: rectForContentViewMask()).CGPath
		contentView.layer.mask = mask
	}

	private func rectForContentView(x x: CGFloat) -> CGRect {
		var rect = contentView.bounds
		rect.origin.x = x
		rect.origin.y += yContentOffset
		return rect
	}

	private func rectForBackgroundView() -> CGRect {
		var rect = self.rect
		rect.origin.x = 0
		rect.size.width = contentView.bounds.size.width
		return rect
	}

	private func rectForContentViewMask() -> CGRect {
		var rect = self.rect
		rect.origin.x = 0
		rect.origin.y -= yContentOffset
		rect.size.width = contentView.bounds.size.width
		return rect
	}
}
