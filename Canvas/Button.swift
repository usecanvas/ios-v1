//
//  Button.swift
//  Canvas
//
//  Created by Sam Soffes on 11/25/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class Button: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = Color.brand
		layer.cornerRadius = 4
		titleLabel?.font = .boldSystemFontOfSize(18)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
