//
//  TableViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 11/23/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import Static

class TableViewController: UITableViewController {

	// MARK: - Properties

	/// Table view data source.
	var dataSource = DataSource() {
		willSet {
			dataSource.tableView = nil
		}

		didSet {
			dataSource.tableView = tableView
		}
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		clearsSelectionOnViewWillAppear = false
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
