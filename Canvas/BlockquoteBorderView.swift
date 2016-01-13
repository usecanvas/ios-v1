//
//  BlockquoteBorderView.swift
//  Canvas
//
//  Created by Sam Soffes on 11/20/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit

final class BlockquoteBorderView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		userInteractionEnabled = false
		backgroundColor = UIColor(red: 0.925, green: 0.925, blue: 0.929, alpha: 1)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}
