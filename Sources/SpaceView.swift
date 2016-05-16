//
//  SpaceView.swift
//  Canvas
//
//  Created by Sam Soffes on 5/16/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

/// Space view intented to be used with auto layout.
/// Similar to UIStackView, setting a background color is not supported.
final class SpaceView: UIView {

	// MARK: - Properties

	private let contentSize: CGSize


	// MARK: - Initializers

	init(size: CGSize) {
		contentSize = size
		super.init(frame: .zero)
	}

	convenience init(height: CGFloat) {
		self.init(size: CGSize(width: UIViewNoIntrinsicMetric, height: height))
	}

	convenience init(width: CGFloat) {
		self.init(size: CGSize(width: width, height: UIViewNoIntrinsicMetric))
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class func layerClass() -> AnyClass {
		return CATransformLayer.self
	}

	override func intrinsicContentSize() -> CGSize {
		return contentSize
	}
}


extension UIStackView {
	func addSpace(length: CGFloat) {
		switch axis {
		case .Horizontal: addArrangedSubview(SpaceView(width: length))
		case .Vertical: addArrangedSubview(SpaceView(height: length))
		}
	}
}
