//
//  NavigationBar.swift
//  Canvas
//
//  Created by Sam Soffes on 2/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore

final class NavigationBar: UINavigationBar {

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

	private let borderView: LineView = {
		let view = LineView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		barTintColor = Swatch.white
		translucent = false
		shadowImage = UIImage()
		backIndicatorImage = UIImage(named: "ChevronLeft")
		backIndicatorTransitionMaskImage = UIImage(named: "ChevronLeft")

		borderColor = Swatch.border

		addSubview(borderView)

		NSLayoutConstraint.activateConstraints([
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
			NSFontAttributeName: Font.sansSerif(weight: .medium),
			NSForegroundColorAttributeName: tintAdjustmentMode == .Dimmed ? tintColor : (titleColor ?? Swatch.darkGray)
		]
	}
}
