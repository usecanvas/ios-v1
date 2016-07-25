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
			imageView.trailingAnchor.constraintEqualToAnchor(trailingAnchor, constant: -8).active = true
		} else {
			imageView.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 8).active = true
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
