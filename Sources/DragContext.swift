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
	let block: BlockNode
	let contentView: UIView
	let backgroundView = UIView()
	let rect: CGRect
	let yContentOffset: CGFloat
	var dragAction: DragAction? = nil

	init(block: BlockNode, contentView: UIView, rect: CGRect, yContentOffset: CGFloat) {
		self.block = block
		self.contentView = contentView
		self.rect = rect
		self.yContentOffset = yContentOffset

		contentView.userInteractionEnabled = false
		backgroundView.userInteractionEnabled = false
	}

	func rectForContentView(x x: CGFloat) -> CGRect {
		var rect = contentView.bounds
		rect.origin.x = x
		rect.origin.y += yContentOffset
		return rect
	}

	func rectForContentViewMask() -> CGRect {
		var rect = self.rect
		rect.origin.x = 0
		rect.origin.y -= yContentOffset
		rect.size.width = contentView.bounds.size.width
		return rect
	}

	func rectForBackgroundView() -> CGRect {
		var rect = self.rect
		rect.origin.x = 0
		rect.size.width = contentView.bounds.size.width
		return rect
	}

	func tearDown() {
		backgroundView.removeFromSuperview()
		contentView.removeFromSuperview()
	}
}
