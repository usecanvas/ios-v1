//
//  CanvasesResultsViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 12/9/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasKit

protocol CanvasesResultsViewControllerDelegate: class {
	func canvasesResultsViewController(viewController: CanvasesResultsViewController, didSelectCanvas canvas: Canvas)
}

class CanvasesResultsViewController: CanvasesViewController {

	// MARK: - Properties

	weak var delegate: CanvasesResultsViewControllerDelegate?


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let line = LineView()
		line.translatesAutoresizingMaskIntoConstraints = false
		line.backgroundColor = Color.gray
		view.addSubview(line)

		NSLayoutConstraint.activateConstraints([
			// Add search bar height :(
			line.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 44),
			
			line.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			line.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor)
		])
	}


	// MARK: - Actions

	override func openCanvas(canvas: Canvas) {
		delegate?.canvasesResultsViewController(self, didSelectCanvas: canvas)
	}
}
