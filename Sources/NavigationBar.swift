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

	var borderColor: UIColor? {
		set {
			borderView.backgroundColor = newValue
		}

		get {
			return borderView.backgroundColor
		}
	}

	private let bottomView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let borderView: LineView = {
		let view = LineView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		barTintColor = Color.white
		translucent = false
		shadowImage = UIImage()
		backIndicatorImage = UIImage(named: "ChevronLeft")
		backIndicatorTransitionMaskImage = UIImage(named: "ChevronLeft")

		bottomView.backgroundColor = barTintColor
		borderColor = Color.navigationBarBorder

		addSubview(bottomView)
		addSubview(borderView)

		NSLayoutConstraint.activateConstraints([
			bottomView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
			bottomView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			bottomView.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
			bottomView.heightAnchor.constraintEqualToConstant(2),

			borderView.topAnchor.constraintEqualToAnchor(bottomAnchor),
			borderView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
			borderView.trailingAnchor.constraintEqualToAnchor(trailingAnchor)
		])
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
			NSForegroundColorAttributeName: tintAdjustmentMode == .Dimmed ? tintColor : (titleColor ?? Color.gray)
		]
	}
}
