//
//  PlaceholderViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/10/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController {

	// MARK: - Properties

	private let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "No Canvas Selected"
		label.textColor = Color.darkGray
		label.font = Font.sansSerif()
		return label
	}()


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .whiteColor()

		view.addSubview(textLabel)

		NSLayoutConstraint.activateConstraints([
			textLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			textLabel.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
		])

		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
		navigationItem.leftItemsSupplementBackButton = true
	}
}
