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

	weak var delegate: CanvasesResultsViewControllerDelegate?

	override func selectModel(model: Model) {
		guard let canvas = model as? Canvas else { return }
		delegate?.canvasesResultsViewController(self, didSelectCanvas: canvas)
	}
}
