//
//  PlaceholderViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasText

class PlaceholderViewController: UIViewController {

	// MARK: - Properties

	private let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "No Canvas Selected"
		label.textColor = Swatch.gray
		label.font = TextStyle.Body.font()
		return label
	}()


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Swatch.white

		view.addSubview(textLabel)

		NSLayoutConstraint.activateConstraints([
			textLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			textLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
		])
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		UIDevice.currentDevice().batteryMonitoringEnabled = false
	}
}
