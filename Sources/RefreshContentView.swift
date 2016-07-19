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
//		switch state {
//		case .Closed, .Opening:
//			statusLabel.text = NSLocalizedString("Pull down to refresh", comment: "")
//			statusLabel.alpha = 1
//			activityIndicatorView.stopAnimating()
//			activityIndicatorView.alpha = 0
//		case.Ready:
//			statusLabel.text = NSLocalizedString("Release to refresh", comment: "")
//			statusLabel.alpha = 1
//			activityIndicatorView.stopAnimating()
//			activityIndicatorView.alpha = 0
//		case .Refreshing:
//			statusLabel.alpha = 0
//			activityIndicatorView.startAnimating()
//			activityIndicatorView.alpha = 1
//		case .Closing:
//			statusLabel.text = nil
//			activityIndicatorView.alpha = 0
//		}
	}

	private func updateProgress() {
		let height = dimension * (progress / 2)
		backgroundMaskLayer.path = UIBezierPath(roundedRect: CGRectMake(0, dimension - height, dimension, height), cornerRadius: 4).CGPath
	}
}
