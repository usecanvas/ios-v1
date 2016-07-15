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

final class PlaceholderViewController: UIViewController {

	// MARK: - Properties

	private let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "No Canvas Selected"
		label.textColor = Swatch.darkGray
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
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateFont), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		updateFont()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		UIDevice.currentDevice().batteryMonitoringEnabled = false
	}
	
	
	// MARK: - Private
	
	@objc private func updateFont() {
		textLabel.font = TextStyle.body.font()
	}
}
