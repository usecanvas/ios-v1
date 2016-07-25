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

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = Swatch.lightGray
		userInteractionEnabled = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
