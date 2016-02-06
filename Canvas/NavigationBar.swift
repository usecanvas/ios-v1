//
//  NavigationBar.swift
//  Canvas
//
//  Created by Sam Soffes on 2/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {

	// MARK: - Properties

	var titleColor: UIColor? {
		didSet {
			updateTitleColor()
		}
	}


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		barTintColor = .whiteColor()
		translucent = false
		shadowImage = UIImage()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func tintColorDidChange() {
		super.tintColorDidChange()
		updateTitleColor()
	}


	// MARK: - Private

	private func updateTitleColor() {
		titleTextAttributes = [
			NSFontAttributeName: Font.sansSerif(weight: .Bold),
			NSForegroundColorAttributeName: tintAdjustmentMode == .Dimmed ? tintColor : (titleColor ?? .blackColor())
		]
	}
}
