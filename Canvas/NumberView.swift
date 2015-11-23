//
//  NumberView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/20/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class NumberView: UILabel {

	// MARK: - Initializers

	init(frame: CGRect, value: UInt) {
		super.init(frame: frame)

		text = "\(value)."
		textAlignment = .Right
		textColor = Color.gray
		font = .systemFontOfSize(Theme.baseFontSize - (value > 99 ? 2 : 0))
//		adjustsFontSizeToFitWidth = true
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
