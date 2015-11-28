//
//  NumberView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/20/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasText

class NumberView: UILabel {

	// MARK: - Initializers

	init(frame: CGRect, theme: Theme, value: UInt) {
		super.init(frame: frame)

		text = "\(value)."
		textAlignment = .Right
		textColor = Color.gray
		font = theme.fontOfSize(theme.fontSize - (value > 99 ? 2 : 0))
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
