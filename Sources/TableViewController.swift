//
//  TableViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static
import CanvasCore

class TableViewController: UIViewController {

	// MARK: - Properties

	let tableView: UITableView

	/// Table view data source.
	var dataSource = DataSource() {
		willSet {
			dataSource.tableView = nil
		}

		didSet {
			dataSource.tableView = tableView
		}
	}

	// MARK: - Initializers

	init(style: UITableViewStyle) {
		tableView = TableView(frame: .zero, style: style)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.separatorColor = Swatch.border

		dataSource.tableView = tableView

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(tableView)

		NSLayoutConstraint.activateConstraints([
			tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
			tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
			tableView.topAnchor.constraintEqualToAnchor(view.topAnchor),
			tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
		])

		dataSource.automaticallyDeselectRows = false
		dataSource.tableView = tableView
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		tableView.indexPathsForSelectedRows?.forEach { indexPath in
			tableView.deselectRowAtIndexPath(indexPath, animated: false)
		}
	}
}
