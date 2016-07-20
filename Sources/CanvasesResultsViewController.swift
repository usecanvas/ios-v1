//
//  CanvasesResultsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 12/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit

final class CanvasesResultsViewController: CanvasesViewController {

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		canRefresh = false

		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(line)

		NSLayoutConstraint.activateConstraints([
			// Add search bar height :(
			line.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 44),
			
			line.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			line.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor)
		])
	}
}
