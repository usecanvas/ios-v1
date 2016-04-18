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

	init(account: Account, style: UITableViewStyle = .Plain) {
		self.account = account
		super.init(style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		canRefresh = false
		
		tableView.rowHeight = 72

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
	}


	// MARK: - ModelsViewController

	func openCanvas(canvas: Canvas) {
		guard !opening else { return }
		opening = true
		Analytics.track(.OpenedCanvas)
		let viewController = EditorViewController(account: account, canvas: canvas)
		navigationController?.pushViewController(viewController, animated: true)
	}


	// MARK: - Rows

	func rowForCanvas(canvas: Canvas) -> Row {
		var row = canvas.row
		row.selection = { [weak self] in self?.openCanvas(canvas) }
		return row
	}
}
