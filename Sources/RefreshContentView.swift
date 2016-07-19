//
//  RefreshContentView.swift
//  Canvas
//
//  Created by Sam Soffes on 7/18/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import PullToRefresh

final class RefreshContentView: UIView, ContentView {

	// MARK: - Properties

	var state: RefreshView.State = .Closed {
		didSet {
			updateState()
		}
	}

	var progress: CGFloat = 0 {
		didSet {
			updateProgress()
		}
	}

	var lastUpdatedAt: NSDate?

	private let dimension: CGFloat = 48

	private let containerLayer: CALayer = CATransformLayer()

	private let outlineLayer: CALayer = {
		let layer = CALayer()
		layer.contents = UIImage(named: "RefreshViewOutline")!.CGImage
		return layer
	}()

	private let gradientLayer: CALayer = {
		let layer = CALayer()
		layer.contents = UIImage(named: "RefreshViewGradient")!.CGImage
		return layer
	}()

	private let backgroundLayer: CALayer = {
		let layer = CALayer()
		layer.contents = UIImage(named: "RefreshViewBackground")!.CGImage
		return layer
	}()

	private let backgroundMaskLayer = CAShapeLayer()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		layer.addSublayer(containerLayer)
		containerLayer.addSublayer(backgroundLayer)
		backgroundLayer.mask = backgroundMaskLayer
		containerLayer.addSublayer(gradientLayer)
		gradientLayer.mask = outlineLayer

		updateState()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override func layoutSubviews() {
		let size = bounds.size

		containerLayer.frame = CGRectMake(round((size.width - dimension) / 2), round((size.height - dimension) / 2), dimension, dimension)
		backgroundLayer.frame = containerLayer.bounds
		gradientLayer.frame = containerLayer.bounds
		outlineLayer.frame = containerLayer.bounds
		backgroundMaskLayer.frame = containerLayer.bounds
	}


	// MARK: - Private

	private func updateState() {
		switch state {
		case .Refreshing:
			CATransaction.begin()
			let gradientAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
			gradientAnimation.duration = 1
			gradientAnimation.repeatCount = .infinity
			gradientAnimation.fromValue = 0
			gradientAnimation.toValue = M_PI * 2
			gradientLayer.addAnimation(gradientAnimation, forKey: "gradientSpin")

			let maskAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
			maskAnimation.duration = 1
			maskAnimation.repeatCount = .infinity
			maskAnimation.fromValue = 0
			maskAnimation.toValue = -M_PI * 2
			outlineLayer.addAnimation(maskAnimation, forKey: "maskSpin")
			CATransaction.commit()

		case .Closed:
			CATransaction.begin()
			gradientLayer.removeAnimationForKey("gradientSpin")
			outlineLayer.removeAnimationForKey("maskSpin")
			CATransaction.commit()

			progress = 0

		case .Ready, .Closing, .Opening:
			break
		}
	}

	private func updateProgress() {
		var rect = backgroundMaskLayer.bounds
		rect = rect.insetBy(dx: 8, dy: 8)

		let p = state == .Closing ? 1 : progress
		let fullHeight = rect.size.height
		rect.size.height *= min(p, 1)
		rect.origin.y += fullHeight - rect.height

		backgroundMaskLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 2).CGPath
	}
}
