//
//  CanvasesViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 12/8/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasKit

class CanvasesViewController: ModelsViewController, Accountable {

	// MARK: - Properties

	var account: Account


	// MARK: - Initializers

	init(account: Account) {
		self.account = account
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.rowHeight = 72

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
	}


	// MARK: - ModelsViewController

	override var modelTypeName: String {
		return "Canvas"
	}

	override func rowForModel(model: Model, isSelected: Bool) -> Row? {
		guard let canvas = model as? Canvas else { return nil }

		var row = canvas.row
		row.selection = { [weak self] in self?.selectModel(canvas) }

		if isSelected {
			row.cellClass = SelectedCanvasCell.self
		}

		return row
	}

	override func selectModel(model: Model) {
		guard !opening, let canvas = model as? Canvas else { return }
		opening = true
		Analytics.track(.OpenedCanvas)
		let viewController = EditorViewController(account: account, canvas: canvas)
		navigationController?.pushViewController(viewController, animated: true)
	}

	override var canRefresh: Bool {
		return false
	}
}
